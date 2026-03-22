# =================================
# 自定义函数（新架构）
# =================================

# FZF 快速文件搜索
function fzf-file() {
  local file=$(fd --type f --hidden --exclude .git 2>/dev/null |
    fzf --preview "bat --color=always --line-range :20 {} 2>/dev/null || echo 'Preview not available'")
  [[ -n "$file" ]] && ${EDITOR:-nano} "$file"
}

# FZF 快速目录跳转
function fzf-dir() {
  local dir=$(fd --type d --hidden --exclude .git 2>/dev/null |
    fzf --preview "ls -la {}")
  [[ -n "$dir" ]] && cd "$dir"
}

# Claude hooks 查找
function fzf-hooks() {
  local hook=$(fd . ~/.claude/hooks 2>/dev/null |
    fzf --preview "cat {}")
  [[ -n "$hook" ]] && ${EDITOR:-nano} "$hook"
}

# 项目统计
function project-stats() {
  echo "=== 项目统计 ==="
  echo "文件总数: $(fd --type f 2>/dev/null | wc -l)"
  echo "代码行数: $(rg -c '' 2>/dev/null | wc -l)"
}

function yazi() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

claude_print() {
  if [ $# -eq 0 ]; then
    # 无参数时，读取管道输入
    cat | claude -p "$1"
  else
    claude -p "$1"
  fi
}
