#!/bin/bash
set -e

#############################################
# 本地配置快速设置脚本
# 用于设置 API keys 和其他敏感信息
#############################################

DOTFILES=~/dotfiles
LOCAL_CONFIG="$DOTFILES/local/.config/zsh/.zshrc.local"
TEMPLATE="$DOTFILES/zsh/.config/zsh/.zshrc.local.template"

echo "🔧 本地配置设置向导"
echo ""

# 创建目录
mkdir -p "$DOTFILES/local/.config/zsh"

# 检查是否已存在
if [ -f "$LOCAL_CONFIG" ]; then
    echo "⚠️  本地配置文件已存在: $LOCAL_CONFIG"
    read -p "是否要重新配置？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 0
    fi
    cp "$LOCAL_CONFIG" "$LOCAL_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
fi

# 从模板复制
cp "$TEMPLATE" "$LOCAL_CONFIG"

echo "📝 正在配置本地环境变量..."
echo ""

#############################################
# Anthropic API 配置
#############################################
echo "🔑 Anthropic API 配置"
read -p "是否配置 Anthropic API？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "请输入 ANTHROPIC_API_KEY: " api_key
    read -p "请输入 ANTHROPIC_BASE_URL (默认: https://api.anthropic.com): " base_url

    sed -i "s|export ANTHROPIC_API_KEY=\"your-api-key-here\"|export ANTHROPIC_API_KEY=\"$api_key\"|" "$LOCAL_CONFIG"
    sed -i "s|# export ANTHROPIC_BASE_URL=|export ANTHROPIC_BASE_URL=|" "$LOCAL_CONFIG"

    if [ -n "$base_url" ]; then
        sed -i "s|export ANTHROPIC_BASE_URL=\"https://open.bigmodel.cn/api/anthropic\"|export ANTHROPIC_BASE_URL=\"$base_url\"|" "$LOCAL_CONFIG"
    fi
fi

echo ""

#############################################
# GitHub Token 配置
#############################################
echo "🔑 GitHub Token 配置"
read -p "是否配置 GitHub Token？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "请输入 GITHUB_TOKEN: " github_token
    sed -i "s|# export GITHUB_TOKEN=\"your-github-token-here\"|export GITHUB_TOKEN=\"$github_token\"|" "$LOCAL_CONFIG"
fi

echo ""

#############################################
# 其他自定义配置
#############################################
echo "📝 其他配置"
read -p "是否需要添加其他自定义环境变量？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "请输入自定义配置（输入完成后按 Ctrl+D）："
    cat >> "$LOCAL_CONFIG" << 'EOF'

# =================================
# 自定义配置
# =================================
EOF
    cat >> "$LOCAL_CONFIG"
fi

echo ""
echo "✅ 本地配置已创建: $LOCAL_CONFIG"
echo ""
echo "📋 配置预览："
echo "-----------------------------------"
cat "$LOCAL_CONFIG"
echo "-----------------------------------"
echo ""

# 重新链接 local 包
echo "🔗 更新符号链接..."
cd "$DOTFILES"
stow -D local 2>/dev/null || true
stow local

echo ""
echo "✅ 配置完成！"
echo "💡 提示：运行 'source ~/.zshrc' 或重新打开终端以应用更改"
