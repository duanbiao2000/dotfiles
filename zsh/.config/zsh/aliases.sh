# =================================
# 快捷别名（从 .zshrc.bak + 新增）
# =================================

# ZSH 配置（来自 .zshrc.bak 行 112）
alias zshconfig="nvim ~/.config/zsh/.zshrc"
alias zshmodules="cd ~/.config/zsh && ls -la"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# 系统命令
alias ls='exa --color=always --group-directories-first'
alias ll='exa -l --color=always'
alias la='exa -la --color=always'
alias lt='exa --tree'
alias cls='clear'
alias reload='source ~/.zshrc'

# Git 别名
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gs='git status'

# 文件查找（来自 .zshrc.bak 行 137）
# ⚠️ 保持原有定义，与 fzf-dir 冲突解决：使用不同的别名
alias fd='fdfind' # 系统文件查找

# 项目导航快捷键（新增）
alias j='zi'         # zoxide 交互式跳转
alias fdf='fzf-file' # fzf 文件搜索
alias fdd='fzf-dir'  # fzf 目录搜索
alias s='frgl'       # ripgrep + fzf 代码搜索
alias h='fzf-hooks'  # Claude hooks 查找

# Bat 增强版 cat（统一管理）
alias bat='batcat'           # bat 命令（Debian/Ubuntu 上叫 batcat）
alias cat='batcat'           # 用 bat 替代原生的 cat

# Neovim 快捷别名
alias n='nvim'               # 快捷打开 nvim

# Claude Code
alias cc='claude'
alias cpi='claude_print'
alias yy='yazi'
alias zj='zellij'
alias rtldr='tldr --quiet "$(tldr --quiet --list | shuf -n1)"'

alias chrome='/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe'
alias calendar='/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe https://calendar.google.com/calendar'
alias twitter='/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe https://x.com/home'

# 程序员笑话（手动调用）
alias pjoke='bash ~/.openclaw/workspace/programmer-jokes.sh'  # 原始脚本
alias joke='pjoke | cowthink -f tux'                         # cowthink 版本（带装饰）
