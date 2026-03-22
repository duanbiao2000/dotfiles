#!/bin/bash

#############################################
# 依赖检查脚本
# 检查所有必需的工具是否已安装
#############################################

echo "🔍 检查系统依赖..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_tool() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✅${NC} $1: $(command -v $1)"
        return 0
    else
        echo -e "${RED}❌${NC} $1: 未安装"
        return 1
    fi
}

#############################################
# 核心工具
#############################################
echo "📦 核心工具："
check_tool git
check_tool zsh
check_tool stow
check_tool curl
check_tool wget

echo ""

#############################################
# 开发工具
#############################################
echo "🛠️  开发工具："
check_tool vim
check_tool nvim
check_tool tmux
check_tool fzf

echo ""

#############################################
# 版本控制相关
#############################################
echo "🔀 版本控制："
check_tool gh
check_tool lazygit

echo ""

#############################################
# 其他工具
#############################################
echo "🔧 其他工具："
check_tool docker
check_tool python3
check_tool node

echo ""

#############################################
# 检查目录
#############################################
echo "📁 检查目录："

dirs=(
    "$HOME/.oh-my-zsh"
    "$HOME/.tmux/plugins/tpm"
    "$HOME/.fzf"
)

for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅${NC} $dir"
    else
        echo -e "${YELLOW}⚠️  ${NC} $dir (不存在)"
    fi
done

echo ""
echo "💡 提示：运行 $HOME/dotfiles/scripts/install.sh 安装缺失的依赖"
