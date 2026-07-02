#!/usr/bin/env bash
# tmux command palette: fuzzy-search prefix keybindings and tmux commands.
# Bindings run directly; bare commands open the tmux command prompt prefilled.
set -euo pipefail

TAB=$'\t'
client=$(tmux display-message -p '#{client_name}')

# key -> note, from `list-keys -N` (only keys with notes appear here)
declare -A NOTE
while IFS= read -r line; do
  line=${line#* } # drop leading prefix key column ("C-a ")
  key=${line%%[[:space:]]*}
  note=${line#"$key"}
  note=${note#"${note%%[![:space:]]*}"}
  NOTE[$key]=$note
done < <(tmux list-keys -N -T prefix)

entries() {
  # bind<TAB>key<TAB>description<TAB>command
  while IFS= read -r line; do
    rest=${line#bind-key}
    rest=${rest#"${rest%%[![:space:]]*}"}
    if [[ $rest == -r* ]]; then
      rest=${rest#-r}
      rest=${rest#"${rest%%[![:space:]]*}"}
    fi
    rest=${rest#-T prefix}
    rest=${rest#"${rest%%[![:space:]]*}"}
    key=${rest%%[[:space:]]*}
    cmd=${rest#"$key"}
    cmd=${cmd#"${cmd%%[![:space:]]*}"}
    ukey=${key#\\} # list-keys escapes keys like \# but list-keys -N does not
    printf 'bind\t%s\t%s\t%s\n' "$ukey" "${NOTE[$ukey]:-$cmd}" "$cmd"
  done < <(tmux list-keys -T prefix)

  # cmd<TAB>name<TAB>usage<TAB>name
  while IFS= read -r line; do
    printf 'cmd\t%s\t%s\t%s\n' "${line%% *}" "$line" "${line%% *}"
  done < <(tmux list-commands)
}

sel=$(entries | fzf --delimiter="$TAB" --with-nth=2,3 --tabstop=12 \
  --reverse --prompt='tmux ❯ ' --header='keybindings + commands') || exit 0

type=${sel%%"$TAB"*}
cmd=${sel##*"$TAB"}

# Defer execution until this popup has closed, otherwise commands that open
# their own popup/menu/prompt fail while ours is still on screen.
if [[ $type == bind ]]; then
  tmp=$(mktemp)
  printf '%s\n' "$cmd" >"$tmp"
  # source-file uses tmux's own parser, which handles quotes and {} blocks
  tmux run-shell -b "sleep 0.1; tmux source-file '$tmp'; rm -f '$tmp'"
else
  tmux run-shell -b "sleep 0.1; tmux command-prompt -t '$client' -I '$cmd '"
fi
