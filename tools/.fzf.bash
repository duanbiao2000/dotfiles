# Setup fzf
# ---------
if [[ ! "$PATH" == */home/danny/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/danny/.fzf/bin"
fi

eval "$(fzf --bash)"
