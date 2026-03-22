#!/bin/bash
set -e

#############################################
# Dotfiles 一键安装脚本
# 适用于新机器快速部署
#############################################

DOTFILES=~/dotfiles
cd "$DOTFILES"

echo "🚀 开始安装 dotfiles..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#############################################
# 1. 检查并安装依赖
#############################################
echo "📦 检查依赖..."

# 检查 Stow
if ! command -v stow &> /dev/null; then
    echo -e "${YELLOW}⚠️  GNU Stow 未安装，正在安装...${NC}"
    sudo apt update
    sudo apt install -y stow
else
    echo -e "${GREEN}✅ GNU Stow 已安装${NC}"
fi

# 检查 Git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git 未安装，正在安装...${NC}"
    sudo apt install -y git
else
    echo -e "${GREEN}✅ Git 已安装${NC}"
fi

# 检查 Zsh
if ! command -v zsh &> /dev/null; then
    echo -e "${YELLOW}⚠️  Zsh 未安装，正在安装...${NC}"
    sudo apt install -y zsh
else
    echo -e "${GREEN}✅ Zsh 已安装${NC}"
fi

echo ""

#############################################
# 2. 备份现有配置
#############################################
echo "📦 备份现有配置..."
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 需要备份的文件列表
backup_files=(
    ".zshrc"
    ".vimrc"
    ".tmux.conf"
    ".gitconfig"
    ".bashrc"
    ".p10k.zsh"
    ".fzf.zsh"
    ".fzf.bash"
)

backup_dirs=(
    ".config/zsh"
    ".config/nvim"
    ".config/git"
    ".config/lazygit"
    ".config/yazi"
    ".config/zellij"
    ".config/fish"
    ".vim"
    ".tmux"
)

for file in "${backup_files[@]}"; do
    if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        mv "$HOME/$file" "$BACKUP_DIR/"
        echo -e "${GREEN}✅ 已备份: $file${NC}"
    fi
done

for dir in "${backup_dirs[@]}"; do
    if [ -e "$HOME/$dir" ] && [ ! -L "$HOME/$dir" ]; then
        mv "$HOME/$dir" "$BACKUP_DIR/"
        echo -e "${GREEN}✅ 已备份: $dir${NC}"
    fi
done

echo "💾 备份已保存到: $BACKUP_DIR"
echo ""

#############################################
# 3. 创建符号链接
#############################################
echo "🔗 创建符号链接..."

# 创建本地配置目录
mkdir -p "$DOTFILES/local/.config/zsh"

# 检查本地配置
if [ ! -f "$DOTFILES/local/.config/zsh/.zshrc.local" ]; then
    echo -e "${YELLOW}⚠️  本地配置文件不存在${NC}"
    echo "📝 如果需要配置本地环境变量（API keys 等），请运行："
    echo "   $DOTFILES/scripts/setup-local.sh"
    echo ""
fi

# 链接所有包
packages=("zsh" "vim" "nvim" "tmux" "git" "tools" "p10k" "bash" "local")

for package in "${packages[@]}"; do
    if [ -d "$DOTFILES/$package" ]; then
        echo -e "${GREEN}🔗 链接 $package...${NC}"
        stow "$package" 2>/dev/null || echo -e "${YELLOW}⚠️  $package 链接失败（可能已存在）${NC}"
    fi
done

echo ""

#############################################
# 4. 安装 Oh My Zsh（如果需要）
#############################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc || true
else
    echo -e "${GREEN}✅ Oh My Zsh 已安装${NC}"
fi

echo ""

#############################################
# 5. 安装 Zsh 插件
#############################################
echo "📦 检查 Zsh 插件..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "📦 安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "📦 安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

echo ""

#############################################
# 6. 安装 TPM（Tmux 插件管理器）
#############################################
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "📦 安装 TPM (Tmux 插件管理器)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo -e "${GREEN}✅ TPM 已安装${NC}"
fi

echo ""

#############################################
# 7. 安装 FZF
#############################################
if [ ! -f "$HOME/.fzf.zsh" ]; then
    echo "📦 安装 FZF..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
else
    echo -e "${GREEN}✅ FZF 已安装${NC}"
fi

echo ""

#############################################
# 8. 完成
#############################################
echo -e "${GREEN}✅ Dotfiles 安装完成！${NC}"
echo ""
echo "📋 后续步骤："
echo "   1. 重新加载 shell: exec zsh"
echo "   2. 在 tmux 中安装插件: 按 prefix + I"
echo "   3. (可选) 配置本地环境变量: $DOTFILES/scripts/setup-local.sh"
echo ""
echo "🎉 享受你的新环境吧！"
