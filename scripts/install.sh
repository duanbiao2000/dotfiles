#!/bin/bash
set -e

DOTFILES=~/dotfiles

cd "$DOTFILES"

echo "📦 Installing dotfiles using Stow..."

# 检查 stow 是否安装
if ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow not found. Installing..."
    sudo apt update && sudo apt install -y stow
fi

# 创建本地配置目录
mkdir -p "$DOTFILES/local/.config/zsh"

# 提示用户创建本地配置
if [ ! -f "$DOTFILES/local/.config/zsh/.zshrc.local" ]; then
    echo "⚠️  Local config not found. Please create it from template:"
    echo "   cp $DOTFILES/zsh/.config/zsh/.zshrc.local.template $DOTFILES/local/.config/zsh/.zshrc.local"
    echo "   Then edit with your API keys and secrets."
fi

# 链接所有包
for package in zsh vim tmux git nvim tools p10k bash local; do
    if [ -d "$DOTFILES/$package" ]; then
        echo "🔗 Linking $package..."
        stow "$package"
    fi
done

echo "✅ Dotfiles installed successfully!"
echo "🔄 Restart your shell to apply changes."
