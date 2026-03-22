# =================================
# 其他工具配置
# =================================

if command -v delta &> /dev/null; then
  export GIT_PAGER='delta'
fi

if command -v yazi &> /dev/null; then
  alias y='yazi'
fi
