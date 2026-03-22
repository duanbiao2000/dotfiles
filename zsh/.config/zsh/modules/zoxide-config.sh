# =================================
# Zoxide 配置模块
# =================================

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  
  function zi() {
    local result
    result="$(zoxide query --interactive)" && cd "$result"
  }
  
  function zif() {
    cd "$(zoxide query --list | fzf --preview 'ls -la {}')"
  }
fi
