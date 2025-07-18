#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DEST="$HOME/.config"

echo "🔗 Restoring symlinks from $CONFIG_SRC to $CONFIG_DEST..."

# Ensure ~/.config exists
mkdir -p "$CONFIG_DEST"

for dir in "$CONFIG_SRC"/*/; do
    [ -d "$dir" ] || continue  # skip non-directories

    base=$(basename "$dir")
    target="$CONFIG_DEST/$base"

    if [ -L "$target" ]; then
        echo "🧹 Removing existing symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        echo "⚠️  Skipping existing non-symlink: $target"
        continue
    fi

    ln -s "$dir" "$target"
    echo "✅ Linked $target → $dir"
done

echo "🎉 All eligible configs restored."
