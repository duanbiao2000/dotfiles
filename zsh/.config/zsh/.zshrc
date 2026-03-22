# ============================================
# 1. 性能分析（可选）
# ============================================
# zmodload zsh/zprof

# ============================================
# 2. Powerlevel10k Instant Prompt（必须最前）
# ============================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================
# 2.5 延迟加载外部工具（避免 instant prompt 警告）
# ============================================
_lazy_load_tools() {
  # 只执行一次
  (( $+_lazy_tools_loaded )) && return
  _lazy_tools_loaded=1

  # OpenClaw 配置（重定向输出避免警告）
  if command -v openclaw >/dev/null 2>&1; then
    source <(openclaw completion --shell zsh 2>/dev/null)
    [ -f "/home/danny/.openclaw/env" ] && source "/home/danny/.openclaw/env" >/dev/null 2>&1
  fi

  # x-cmd 和 Terminal Velocity 改为按需延迟加载
  # 见下方 _lazy_load_xcmd 和 _lazy_load_tv 函数
}

# ============================================
# 2.6 按需延迟加载工具（第一次调用时自动初始化）
# ============================================

# Terminal Velocity 延迟加载
tv() {
  if [[ -z "${_tv_init_done:-}" ]]; then
    export _tv_init_done=1
    if command -v tv >/dev/null 2>&1; then
      eval "$(tv init zsh 2>/dev/null)" >/dev/null 2>&1
    fi
  fi
  command tv "$@"
}

# x-cmd 延迟加载（如果需要）
# x-cmd 通常不需要在 shell 启动时加载
# 使用时直接调用 x 命令即可
x() {
  if [[ -z "${_xcmd_init_done:-}" ]]; then
    export _xcmd_init_done=1
    [[ -f "$HOME/.x-cmd.root/X" ]] && . "$HOME/.x-cmd.root/X" >/dev/null 2>&1
  fi
  # 如果 x-cmd 定义了 x 函数，移除我们的包装函数
  if typeset -f x | grep -q "x-cmd"; then
    unfunction x
  fi
  command x "$@" 2>/dev/null || return 0
}

# 在 prompt 显示后立即自动加载（平滑无感知）
autoload -Uz add-zsh-hook
add-zsh-hook precmd _lazy_load_tools

# ============================================
# 3. ZDOTDIR 和模块化配置
# ============================================
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

# 加载初始化脚本（P10k + Oh My Zsh + FZF）
if [[ -f "$ZDOTDIR/init.sh" ]]; then
  source "$ZDOTDIR/init.sh"
fi

# 加载基础配置
for config in "$ZDOTDIR"/{exports,aliases,functions,keybindings}.sh; do
  [[ -f "$config" ]] && source "$config"
done

# 加载所有模块
for module in "$ZDOTDIR/modules"/*.sh; do
  [[ -f "$module" ]] && source "$module"
done

# 本地配置（不上传 git）
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"

# ============================================
# 4. 外部工具配置（已移至延迟加载）
# ============================================
# OpenClaw 配置
# source <(openclaw completion --shell zsh)
# [ -f "/home/danny/.openclaw/env" ] && source "/home/danny/.openclaw/env"

# x-cmd
# [ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X"

# Terminal Velocity
# eval "$(tv init zsh)"

# ============================================
# 5. 启动动画（异步，不阻塞 - 已移至延迟加载）
# ============================================
# if command -v quote >/dev/null 2>&1 && command -v cowthink >/dev/null 2>&1; then
#   (
#     echo ""
#     echo "──────────────────────────────────"
#     pjoke | cowthink -f tux
#     echo "──────────────────────────────────"
#     echo ""
#   ) &
# fi

# ============================================
# 6. 性能报告（可选）
# ============================================
#zprof
