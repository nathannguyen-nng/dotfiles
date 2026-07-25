#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DEST="$HOME/.config"

# Symlink src -> dest, replacing an existing symlink but never a real file/dir.
link() {
  local src=$1 dest=$2
  if [ ! -e "$src" ]; then
    echo "⚠️  Missing source, skipping: $src"
    return 0
  fi
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "⚠️  Skipping existing non-symlink: $dest"
    return 0
  fi
  ln -s "$src" "$dest"
  echo "✅ Linked $dest → $src"
}

echo "🔗 Restoring symlinks from $CONFIG_SRC to $CONFIG_DEST..."
mkdir -p "$CONFIG_DEST"

# Dirs in config/ that should not be linked into ~/.config
SKIP="ssh nvim_bak launchd"

for dir in "$CONFIG_SRC"/*/; do
  base=$(basename "$dir")
  case " $SKIP " in *" $base "*) continue ;; esac
  link "${dir%/}" "$CONFIG_DEST/$base"
done

echo "🔗 Linking home dotfiles..."
link "$CONFIG_SRC/zsh/zshrc" "$HOME/.zshrc"
link "$CONFIG_SRC/hushlogin" "$HOME/.hushlogin"

mkdir -p "$HOME/.ssh"
link "$CONFIG_SRC/ssh/config" "$HOME/.ssh/config"

echo "🔗 Linking LaunchAgents..."
mkdir -p "$HOME/Library/LaunchAgents"
for plist in "$CONFIG_SRC"/launchd/*.plist; do
  [ -e "$plist" ] || continue
  base=$(basename "$plist")
  dest="$HOME/Library/LaunchAgents/$base"
  link "$plist" "$dest"
  label="${base%.plist}"
  if ! launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1; then
    launchctl bootstrap "gui/$(id -u)" "$dest" && echo "✅ Bootstrapped $label"
  fi
done

echo "🎉 All eligible configs restored."
