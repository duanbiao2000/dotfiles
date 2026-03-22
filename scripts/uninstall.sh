#!/bin/bash
set -e

DOTFILES=~/dotfiles
cd "$DOTFILES"

echo "🗑️  Uninstalling dotfiles using Stow..."

for package in local bash p10k tools nvim git tmux vim zsh; do
    if [ -d "$DOTFILES/$package" ]; then
        echo "❌ Unlinking $package..."
        stow -D "$package"
    fi
done

echo "✅ Dotfiles unlinked successfully!"
echo "📁 Your original files are still in ~/dotfiles-backup/ if needed."
