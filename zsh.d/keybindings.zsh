# ================================================================================
# Key bindings (queued AFTER deferred plugins load — depends on
# zsh-history-substring-search)
# ================================================================================
# Bind both normal (^[[A) and application-mode (^[OA) arrow sequences
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down

# Jump to the next `%` marker right of the cursor and delete it. zsh-abbr only places the
# cursor at the first marker, so this reaches the rest (e.g. the message in `git cfeat`).
_jump_next_marker() {
  local pos=${RBUFFER[(i)%]}
  (( pos > ${#RBUFFER} )) && return
  RBUFFER="${RBUFFER[1,pos-1]}${RBUFFER[pos+1,-1]}"
  CURSOR=$(( CURSOR + pos - 1 ))
}
zle -N _jump_next_marker
bindkey '^[;' _jump_next_marker
