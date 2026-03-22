# Dotfiles

使用 GNU Stow 管理的配置文件。

## 安装

1. 克隆仓库: `git clone https://github.com/duanbiao2000/dotfiles.git ~/dotfiles`
2. 运行安装脚本: `cd ~/dotfiles && ./scripts/install.sh`

## 结构

- `zsh/` - Zsh 配置（包括 .zshrc, aliases, functions 等）
- `vim/` - Vim 配置
- `nvim/` - Neovim (LazyVim) 配置
- `tmux/` - Tmux 配置
- `git/` - Git 配置
- `tools/` - 其他工具（lazygit, yazi, zellij 等）
- `bash/` - Bash 配置
- `p10k/` - Powerlevel10k 配置
- `local/` - 本地配置（不提交到 Git）

## 使用 Stow

```bash
cd ~/dotfiles

# 启用包
stow zsh

# 禁用包
stow -D zsh

# 查看哪些文件会被链接（不实际执行）
stow -n zsh
```

## 本地配置

复制模板并填入真实信息：
```bash
cp ~/dotfiles/zsh/.config/zsh/.zshrc.local.template ~/dotfiles/local/.config/zsh/.zshrc.local
# 编辑文件填入真实的 API keys
stow local
```

## 新机器上的快速部署

```bash
# 1. 安装基础工具
sudo apt update && sudo apt install -y stow git zsh

# 2. 克隆仓库
git clone https://github.com/duanbiao2000/dotfiles.git ~/dotfiles

# 3. 运行安装脚本
cd ~/dotfiles
./scripts/install.sh

# 4. 配置本地信息
cp ~/dotfiles/zsh/.config/zsh/.zshrc.local.template ~/dotfiles/local/.config/zsh/.zshrc.local
# 编辑 .zshrc.local 填入 API keys
stow local

# 5. 重启 shell
exec zsh
```
