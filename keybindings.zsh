# ================================================================================
# Key bindings (queued AFTER deferred plugins load — depends on
# zsh-history-substring-search)
# ================================================================================
# Bind both normal (^[[A) and application-mode (^[OA) arrow sequences
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down
