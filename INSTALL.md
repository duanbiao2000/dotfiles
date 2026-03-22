# Dotfiles 安装指南

使用 GNU Stow 管理的个人配置文件。

## 🚀 快速安装

### 一键安装（推荐）

```bash
# 克隆仓库
git clone https://github.com/duanbiao2000/dotfiles.git ~/dotfiles

# 运行一键安装脚本
cd ~/dotfiles
./scripts/install.sh

# 重新加载 shell
exec zsh
```

### 手动安装

如果你喜欢手动控制每一步：

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y stow git zsh curl

# 2. 克隆仓库
git clone https://github.com/duanbiao2000/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. 备份现有配置（可选但推荐）
mv ~/.zshrc ~/dotfiles-backup/
mv ~/.vimrc ~/dotfiles-backup/
mv ~/.tmux.conf ~/dotfiles-backup/
# ... 备份其他配置文件

# 4. 创建符号链接
stow zsh
stow vim
stow nvim
stow tmux
stow git
stow tools
stow p10k
stow bash

# 5. 安装 Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# 6. 安装 Zsh 插件
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 7. 安装 FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-fish

# 8. 安装 TPM (Tmux 插件管理器)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 9. 重新加载 shell
exec zsh
```

## 🔑 配置本地环境变量（可选）

如果你需要配置 API keys 或其他敏感信息：

```bash
# 运行配置向导
cd ~/dotfiles
./scripts/setup-local.sh

# 或手动创建
cp ~/dotfiles/zsh/.config/zsh/.zshrc.local.template \
   ~/dotfiles/local/.config/zsh/.zshrc.local
# 编辑文件填入真实的 API keys
vim ~/dotfiles/local/.config/zsh/.zshrc.local

# 重新链接
stow local

# 重新加载
source ~/.zshrc
```

## 📋 检查依赖

运行依赖检查脚本查看系统状态：

```bash
cd ~/dotfiles
./scripts/check-deps.sh
```

## 🧹 卸载

如果需要卸载：

```bash
cd ~/dotfiles
./scripts/uninstall.sh
```

## 📁 目录结构

```
~/dotfiles/
├── bash/       - Bash 配置
├── git/        - Git 配置
├── local/      - 本地配置（敏感信息，不提交到 Git）
├── nvim/       - Neovim (LazyVim) 配置
├── p10k/       - Powerlevel10k 配置
├── scripts/    - 安装和管理脚本
├── tmux/       - Tmux 配置
├── tools/      - 工具配置（lazygit, yazi, zellij 等）
├── vim/        - Vim 配置
└── zsh/        - Zsh 配置
```

## 🔧 日常使用

### 使用 Stow 管理配置

```bash
cd ~/dotfiles

# 启用某个包
stow <package>

# 禁用某个包
stow -D <package>

# 查看会创建哪些链接（不实际执行）
stow -n <package>

# 示例：禁用 vim 配置
stow -D vim

# 重新启用
stow vim
```

### 更新配置

```bash
cd ~/dotfiles

# 编辑配置文件
vim zsh/.config/zsh/aliases.sh

# 提交更改
git add .
git commit -m "Update aliases"
git push
```

### 同步到其他机器

```bash
# 1. 在新机器上克隆
git clone https://github.com/duanbiao2000/dotfiles.git ~/dotfiles

# 2. 运行安装
cd ~/dotfiles
./scripts/install.sh

# 3. 配置本地环境
./scripts/setup-local.sh

# 4. 完成！
exec zsh
```

## 🎯 初始配置检查清单

安装完成后，请检查：

- [ ] Zsh 正常加载，没有报错
- [ ] Powerlevel10k 主题显示正常
- [ ] Git 配置正确（`git config --list`）
- [ ] Neovim 可以正常启动（`nvim`）
- [ ] Tmux 可以正常启动（`tmux`）
- [ ] 在 Tmux 中按 `prefix + I` 安装插件
- [ ] FZF 正常工作（`Ctrl+R` 搜索历史）
- [ ] （可选）配置本地环境变量

## 🐛 常见问题

### Zsh 启动时报错

如果遇到 `compinit` 错误：

```bash
# 清理补全缓存
rm -f ~/.zcompdump*
rm -f ~/.config/zsh/.zcompdump*

# 重新加载
exec zsh
```

### 符号链接冲突

如果 stow 报错说文件冲突：

```bash
# 删除冲突文件（会被符号链接替代）
rm ~/.config/<conflicting-file>

# 重新链接
cd ~/dotfiles
stow <package>
```

### TPM 插件未安装

1. 打开 tmux：`tmux`
2. 按 `prefix + I`（默认 prefix 是 `Ctrl+b`）
3. 等待插件安装完成

## 📞 获取帮助

如有问题，请：
1. 检查 [GitHub Issues](https://github.com/duanbiao2000/dotfiles/issues)
2. 运行 `./scripts/check-deps.sh` 检查依赖
3. 查看备份：`~/dotfiles-backup-*/`

## 📄 许可证

MIT License

---

🎉 享受你的新环境！
