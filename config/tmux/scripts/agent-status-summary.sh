#!/usr/bin/env bash
# Aggregate tmux-agent-sidebar's per-pane @pane_status options (written by its
# Claude/Codex/OpenCode hooks) into a single summary string, the same idea as
# tmux-agent-status's old status-line.sh but sourced from tmux-agent-sidebar's
# documented scripting interface (@pane_status / @pane_attention pane options).

running=0
waiting=0
error=0
idle=0

while IFS= read -r status; do
    case "$status" in
        running|background) ((running++)) ;;
        waiting) ((waiting++)) ;;
        error) ((error++)) ;;
        idle) ((idle++)) ;;
    esac
done < <(tmux list-panes -a -F '#{@pane_status}' 2>/dev/null)

total=$((running + waiting + error + idle))

if [ "$total" -eq 0 ]; then
    echo ""
else
    # Nerd Font icons (not emoji) for consistent single-cell width -- emoji
    # like ⚡/⏸/✓ render at inconsistent widths depending on terminal/font,
    # which throws off the spacing between segments.
    parts=("#[fg=yellow,bold] ${running}#[default]" "#[fg=cyan,bold] ${waiting}#[default]" "#[fg=green,bold] ${idle}#[default]")
    [ "$error" -gt 0 ] && parts+=("#[fg=red,bold] ${error}#[default]")

    IFS=' '
    echo "${parts[*]}"
fi
