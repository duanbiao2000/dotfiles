# =================================
# Git 配置模块
# =================================

if command -v git &> /dev/null; then
  function fgl() {
    git log --oneline 2>/dev/null | \
    fzf --preview "git show --color=always {1}" \
        --preview-window=right:70%
  }

  function fgd() {
    git diff --name-only 2>/dev/null | \
    fzf --preview "git diff --color=always {}"
  }

  function fga() {
    git add $(git diff --name-only 2>/dev/null | fzf -m)
  }
fi
