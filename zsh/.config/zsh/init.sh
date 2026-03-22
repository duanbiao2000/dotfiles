# =================================
# 初始化脚本（核心框架）
# =================================
# 注意：P10k instant prompt 已在 .zshrc 中配置（必须在所有配置之前）

# Oh My Zsh 配置
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

# 合并插件列表（取并集）
export plugins=(
  git
  docker
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  rand-quote
  sudo
  extract
  kubectl
  hitokoto
  hitchhiker
  tmux
)

# 加载 Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Powerlevel10k 自定义配置
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# FZF 初始化
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zsh 选项
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
