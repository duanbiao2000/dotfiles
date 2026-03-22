# =================================
# 环境变量（从 .zshrc.bak 迁移 + locale 修复）
# =================================

# ⚠️ Locale 配置（修复：使用 C.UTF-8 而非 en_US.UTF-8）
# WSL 系统默认只支持 C, C.utf8, POSIX locale
# C.UTF-8 等同于 en_US.UTF-8，支持 UTF-8 编码且兼容性更好
export LANG="C.UTF-8"
export LC_ALL="" # 清除 LC_ALL，让 LANG 生效

# Homebrew 配置
# Linuxbrew 在 Linux 系统上的 Homebrew 实现
# 设置 Homebrew 前缀路径和相关环境变量（PATH、MANPATH、INFOPATH 等）
# 这是 Homebrew 在 Linux 上的标准初始化方式
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export EDITOR="nvim"
export PAGER="less"

# ⚠️ 重要：移除 Windows npm 路径（WSL 优先）
# 这是 .zshrc.bak 行 123 的关键配置
export PATH="${PATH/\/mnt\/c\/Users\/danny\/AppData\/Roaming\/npm:/}"

# PNPM 配置（来自 .zshrc.bak 行 125-130）
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Rust/Cargo 配置（来自 .zshrc.bak 行 132-135）
export PATH="$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# NVM 配置（来自 .zshrc.bak 行 118-120）
# 原来这三行先全部注释掉  (启动会变慢)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
# 可选：自动用默认版本
nvm use default >/dev/null 2>&1

# ---- Lazy-load NVM（推荐方案）---- (和npm prefix语法冲突)
# export NVM_DIR="$HOME/.nvm"

# 将 nvm 管理的 node 的全局 bin 加进 PATH
npm_prefix=$(npm prefix -g 2>/dev/null)
if [ -n "$npm_prefix" ] && [ -d "$npm_prefix/bin" ]; then
  export PATH="$npm_prefix/bin:$PATH"
fi
