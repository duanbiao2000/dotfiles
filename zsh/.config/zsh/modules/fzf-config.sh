# =================================
# FZF 配置模块
# =================================

export FZF_DEFAULT_OPTS='
  --height 50%
  --reverse
  --multi
  --preview-window=right:60%
  --preview "if [[ -d {1} ]]; then ls -la {1}; else head -20 {1}; fi" --delimiter ":"
  --bind "ctrl-a:select-all"
  --bind "ctrl-d:deselect-all"
  --bind "ctrl-p:toggle-preview"
'