# 🚀 新机器快速部署

## 一键安装

```bash
# 1. 克隆并安装
git clone https://github.com/duanbiao2000/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./scripts/install.sh

# 2. 配置本地环境（可选，5秒完成）
cp ~/dotfiles/zsh/.config/zsh/.zshrc.local.template ~/dotfiles/local/.config/zsh/.zshrc.local
vim ~/dotfiles/local/.config/zsh/.zshrc.local  # 编辑填入 API keys
stow local

# 3. 完成！重新加载 shell
exec zsh
```

## 本地配置模板内容

编辑 `~/dotfiles/local/.config/zsh/.zshrc.local`，填入你的配置：

```bash
# =================================
# 本地环境变量（不上传 git）
# =================================

# 解决 ANTHROPIC 环境变量冲突
unset ANTHROPIC_AUTH_TOKEN
export ANTHROPIC_API_KEY="your-api-key-here"
export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"

# GitHub Token
export GITHUB_TOKEN="your-github-token-here"
```

## 完成！

就这么简单！3 个命令搞定新机器配置。
