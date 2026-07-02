#!/usr/bin/env bash
# Fuzzy-find a dotfiles config and edit it in nvim inside the popup.
# Pinned frequents (★) sort first; loops back to the list until ESC.
set -euo pipefail

cd ~/dotfiles

PINNED=(
  config/zsh/zshrc
  config/ghostty/config
  config/nvim/init.lua
  config/tmux/tmux.conf
  config/sketchybar/sketchybarrc
  config/hammerspoon/init.lua
)

files() {
  printf '★ %s\n' "${PINNED[@]}"
  git ls-files | grep -vxF -f <(printf '%s\n' "${PINNED[@]}")
}

# nvim can't detect light/dark via OSC 11 inside a tmux popup, so ask macOS
if defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
  bg=dark
else
  bg=light
fi

while true; do
  sel=$(files | fzf --reverse --prompt='config ❯ ' \
    --header='enter: edit · esc: quit' \
    --preview 'f={}; bat --color=always --style=numbers "${f#★ }"') || exit 0
  nvim --cmd "set background=$bg" "${sel#★ }"
done
