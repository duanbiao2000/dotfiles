# =================================
# Ripgrep 配置模块
# =================================

if command -v rg &>/dev/null; then
  function frg() {
    local file
    file=$(rg --files-with-matches --no-messages "$1" 2>/dev/null |
      fzf --preview "rg --color=always -A 5 -B 5 '$1' {}")
    [[ -n "$file" ]] && ${EDITOR:-nano} "$file"
  }

  function frgl() {
    local result
    result=$(rg --color=always --line-number --no-heading --smart-case "$1" 2>/dev/null |
      fzf --ansi \
        --delimiter ":" \
        --preview 'batcat --color=always -n --highlight-line {2} {1}' \
        --preview-window=right:50%:+{2}/2)

    if [[ -n "$result" ]]; then
      local file=$(echo "$result" | cut -d: -f1)
      local line=$(echo "$result" | cut -d: -f2)
      ${EDITOR:-nano} "+$line" "$file"
    fi
  }

fi
