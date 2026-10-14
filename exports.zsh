# ================================================================================
# Environment exports (editor, fd/fzf, man, prompt sizing)
# ================================================================================

# COLUMNS is not exported: starship's prompt passes --terminal-width="$COLUMNS"
# itself, and an exported value goes stale for children after a resize.

# Fix right format alignment (prevents right prompt margin issues)
ZLE_RPROMPT_INDENT=0

# Editor
if (( $+commands[hx] )); then
  export EDITOR="hx" VISUAL="hx"
else
  export EDITOR="vi" VISUAL="vi"
fi

# Include hidden files, exclude .git, and intentionally traverse symlinked
# directories. This broadens navigation results and may slow large linked trees.
export FD_OPTIONS="--hidden --follow --exclude .git"

# fzf defaults: good UX + faster-ish
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --cycle
  --info=inline
  --prompt='❯ '
"

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd --type f $FD_OPTIONS"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
fi

# zsh-history-substring-search highlight colors
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=green,bold"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=""

if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi
