#!/usr/bin/env bash
# Keep tmux-agent-sidebar and tmux-resurrect from fighting over sidebar panes.
#
# Without this, a restore produces duplicated/ghost panes for two reasons:
#
#   1. resurrect saves the sidebar as an ordinary pane (its pane_format only
#      captures built-in formats, so @pane_role is never recorded) and restores
#      it as a plain shell. The plugin then has no sidebar it recognises and
#      splits a second one.
#   2. the plugin's `after-new-window` hook fires on every `new-window`
#      resurrect makes, injecting a sidebar *before* resurrect has split the
#      window's remaining panes. That shifts every pane index, so resurrect's
#      `pane_exists` checks make it skip panes it should have created.
#
# The three subcommands below are wired to resurrect's hooks in tmux.conf:
#
#   save         (post-save-layout) tag sidebar pane lines in the save file
#   pre-restore  (pre-restore-all)  suspend the plugin's auto-create hook
#   post-restore (post-restore-all) re-adopt tagged panes, then re-arm the hook
#
# Adoption respawns the saved pane in place rather than killing it and letting
# the plugin re-split, so the restored window keeps exactly the geometry that
# was saved.

set -uo pipefail

# Written into the save file's pane_current_command field. That field is read
# by restore.sh but never used, so it is free real estate for a marker, and
# unlike pane_title it cannot be clobbered by a shell that sets its own title.
SENTINEL='__agent_sidebar__'

# What tmux reports as pane_current_command for the sidebar binary (comm is
# truncated to 15 chars). Kept as a fallback so save files written before this
# script existed still restore cleanly.
LEGACY_COMMAND='tmux-agent-side'

tmux_opt() {
    tmux show-option -gqv "$1" 2>/dev/null
}

resurrect_dir() {
    local path
    path="$(tmux_opt '@resurrect-dir')"
    if [ -z "$path" ]; then
        if [ -d "$HOME/.tmux/resurrect" ]; then
            path="$HOME/.tmux/resurrect"
        else
            path="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
        fi
    fi
    # same expansions resurrect's own helpers.sh applies to @resurrect-dir
    printf '%s\n' "$path" | sed "s,\$HOME,$HOME,g; s,\$HOSTNAME,$(hostname),g; s,~,$HOME,g"
}

# The plugin sets @agent_sidebar_bin but not always @agent_sidebar_dir, so fall
# back to walking up from the binary and finally to the usual TPM location.
sidebar_conf() {
    local dir bin candidate
    dir="$(tmux_opt '@agent_sidebar_dir')"
    [ -n "$dir" ] && [ -r "$dir/agent-sidebar.conf" ] && { printf '%s\n' "$dir/agent-sidebar.conf"; return 0; }

    bin="$(tmux_opt '@agent_sidebar_bin')"
    candidate="$bin"
    for _ in 1 2 3; do
        candidate="$(dirname "$candidate")"
        case "$candidate" in /|.) break ;; esac
        [ -r "$candidate/agent-sidebar.conf" ] && { printf '%s\n' "$candidate/agent-sidebar.conf"; return 0; }
    done

    candidate="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.config/tmux/plugins/}"
    candidate="${candidate%/}/tmux-agent-sidebar/agent-sidebar.conf"
    [ -r "$candidate" ] && { printf '%s\n' "$candidate"; return 0; }
    return 1
}

# --- save ------------------------------------------------------------------

# Tag every pane line that belongs to a live sidebar. Identification comes from
# the plugin's own @pane_role marker, so it does not care what the binary is
# called or what the pane's title happens to be.
cmd_save() {
    local file="${1:-}" coords tmpfile
    [ -n "$file" ] && [ -f "$file" ] || return 0

    coords="$(tmux list-panes -a -F '#{session_name}	#{window_index}	#{pane_index}	#{@pane_role}' 2>/dev/null |
        awk -F'\t' '$4 == "sidebar" { print $1 "\t" $2 "\t" $3 }')"
    [ -n "$coords" ] || return 0

    tmpfile="$(mktemp "${file}.XXXXXX")" || return 0
    if awk -F'\t' -v OFS='\t' -v sentinel="$SENTINEL" '
            NR == FNR { sidebar[$1 SUBSEP $2 SUBSEP $3] = 1; next }
            $1 == "pane" && (($2 SUBSEP $3 SUBSEP $6) in sidebar) { $10 = sentinel }
            { print }
        ' <(printf '%s\n' "$coords") "$file" > "$tmpfile"; then
        # copy rather than mv so the save file keeps its original permissions
        cat "$tmpfile" > "$file"
    fi
    rm -f "$tmpfile"
}

# --- pre-restore -----------------------------------------------------------

cmd_pre_restore() {
    tmux set-option -g @sidebar_auto_create off

    # Drop the plugin's auto-create hook for the duration of the restore. Match
    # the same way the plugin's own agent-sidebar.conf de-dupes it, so a hook
    # belonging to anything else is left alone.
    tmux show-hooks -g after-new-window 2>/dev/null |
        awk '/@agent_sidebar_bin/ && /toggle --create-only/ { print $1 }' |
        while read -r hook; do
            [ -n "$hook" ] && tmux set-hook -gu "$hook"
        done
}

# --- post-restore ----------------------------------------------------------

# Turn a just-restored ghost pane back into a real sidebar: respawn the plugin
# binary in it (same argv and cwd the plugin uses when it splits one) and
# re-apply the @pane_role marker resurrect could not save.
adopt_pane() {
    local session="$1" window="$2" pane="$3" dir="$4" bin="$5"
    local target="${session}:${window}.${pane}" role current

    role="$(tmux display-message -p -t "$target" '#{@pane_role}' 2>/dev/null)" || return 1
    [ "$role" = "sidebar" ] && return 0   # already a live sidebar, nothing to do
    [ -n "$role" ] && return 1

    # Only take over a pane that is still sitting at an untouched shell. If the
    # indexes did not line up (e.g. restoring over a session that has since
    # diverged) we must not blow away one of the user's real panes.
    current="$(tmux display-message -p -t "$target" '#{pane_current_command}' 2>/dev/null)"
    case "$current" in
        zsh|bash|sh|fish|dash|ksh|tcsh|csh|"$LEGACY_COMMAND"|"$SENTINEL") ;;
        *) return 1 ;;
    esac

    # never leave a window with nothing but a sidebar in it
    [ "$(tmux display-message -p -t "${session}:${window}" '#{window_panes}' 2>/dev/null || echo 0)" -gt 1 ] || return 1

    tmux respawn-pane -k -t "$target" -c "$dir" "$bin" 2>/dev/null || return 1
    tmux set-option -p -t "$target" @pane_role sidebar 2>/dev/null
}

# Fallback for a window whose sidebar could not be adopted: let the plugin
# create a fresh one the way it normally would.
create_sidebar() {
    local session="$1" window="$2" bin="$3" window_id pane_path

    window_id="$(tmux display-message -p -t "${session}:${window}" '#{window_id}' 2>/dev/null)" || return 1
    [ -n "$window_id" ] || return 1
    if tmux list-panes -t "$window_id" -F '#{@pane_role}' 2>/dev/null | grep -qx 'sidebar'; then
        return 0
    fi
    pane_path="$(tmux display-message -p -t "$window_id" '#{pane_current_path}' 2>/dev/null)"
    "$bin" toggle --create-only "$window_id" "$pane_path" >/dev/null 2>&1
}

cmd_post_restore() {
    local bin last conf
    bin="$(tmux_opt '@agent_sidebar_bin')"
    last="$(resurrect_dir)/last"

    local -a pending=()
    if [ -n "$bin" ] && [ -x "$bin" ] && [ -r "$last" ]; then
        local session window pane dir command
        while IFS=$'\t' read -r session window pane dir command; do
            case "$command" in
                "$SENTINEL"|"$LEGACY_COMMAND") ;;
                *) continue ;;
            esac
            dir="${dir#:}"          # resurrect prefixes the path with ':'
            dir="${dir//\\ / }"     # ...and backslash-escapes spaces
            adopt_pane "$session" "$window" "$pane" "$dir" "$bin" ||
                pending+=("${session}"$'\t'"${window}")
        # session, window_index, pane_index, pane_current_path, pane_current_command
        done < <(awk -F'\t' -v OFS='\t' '$1 == "pane" { print $2, $3, $6, $8, $10 }' "$last")
    fi

    # Re-arm the plugin's auto-create hook by re-sourcing its config: it strips
    # its own hook entries before re-adding them, so this stays idempotent.
    tmux set-option -g @sidebar_auto_create on
    if conf="$(sidebar_conf)"; then
        tmux source-file "$conf" 2>/dev/null
    fi

    local entry
    for entry in "${pending[@]:-}"; do
        [ -n "$entry" ] || continue
        create_sidebar "${entry%%$'\t'*}" "${entry##*$'\t'}" "$bin"
    done
}

case "${1:-}" in
    save)         shift; cmd_save "$@" ;;
    pre-restore)  cmd_pre_restore ;;
    post-restore) cmd_post_restore ;;
    *)
        echo "usage: ${0##*/} {save <resurrect-file>|pre-restore|post-restore}" >&2
        exit 1
        ;;
esac
