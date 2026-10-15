# ================================================================================
# Directory and file navigation aliases
# ================================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# ================================================================================
# eza aliases
# ================================================================================
alias lse='eza --icons --group-directories-first'
# Long list, sizes in bytes, classify file types, show git status
alias l='eza -lBF --git'
# Long list of directories only, sorted by last modified, with git info
alias llm='eza -lBD --git --sort=modified'
# Detailed long list of all files (incl. hidden), human sizes, ISO time, git info, color scale
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale=all'
# Same as 'la' but also show extended attributes/ACL info
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale=all'

# ---- specialty views ----
# One file per line
alias lS='eza -1 --icons --group-directories-first'
# Tree view (1 level deep)
alias lt='eza --tree --level=1 --group-directories-first --icons=auto'
# Show only hidden (dot) files, avoiding color escape sequences
_zsh_list_hidden() {
  emulate -L zsh
  local -a entries=( .*(DN) )
  (( $#entries )) || return 0
  eza -ad --color=never "$@" -- "${entries[@]}"
}
alias l.='_zsh_list_hidden'

# Without eza, fall back to plain ls (flags accepted by both GNU and BSD ls).
if (( ! $+commands[eza] )); then
  alias lse='ls -F' l='ls -lF' llm='ls -lt' la='ls -lAhF' lx='ls -lAhF' lS='ls -1' lt='ls -F'
  alias l.='ls -d .*'
fi
