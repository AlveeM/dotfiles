# Search with ripgrep once, then fuzzy-filter matching lines.
# Usage: fsearch <pattern> [file or directory ...]
fsearch() {
  emulate -L zsh -o pipefail
  (( $# )) || { print -u2 -- 'usage: fsearch <pattern> [path ...]'; return 1; }
  local pattern=$1
  shift
  rg --line-number --no-heading --color=always -- "$pattern" "$@" | fzf --ansi
}

# NUL-separated selections preserve spaces, newlines and trailing newlines.
# fzf shell-quotes placeholders itself: do not add quotes around {}.

# Fuzzy-pick a directory (with a tree preview) and cd into it.
# Usage: cdf [directory]   (searches under the current directory by default)
cdf() {
  emulate -L zsh
  (( $# <= 1 )) || { print -u2 -- 'usage: cdf [directory]'; return 1; }
  local dir
  IFS= read -r -d '' dir < <(
    setopt pipefail
    fd --type d --print0 ${=FD_OPTIONS} -- . "${1:-.}" |
      fzf --read0 --print0 --no-multi --preview 'eza -T -L 2 --group-directories-first --icons -- {} 2>/dev/null || ls -la -- {}' --preview-window=right:60%
  ) && [[ -n $dir ]] && builtin cd -- "$dir"
}

# Fuzzy-pick a file (with a syntax-highlighted preview) and open it in $EDITOR.
# Usage: fe [directory]   (searches under the current directory by default)
fe() {
  emulate -L zsh
  (( $# <= 1 )) || { print -u2 -- 'usage: fe [directory]'; return 1; }
  local file
  local -a editor
  editor=( ${(z)${EDITOR:-vi}} )
  editor=( "${(@Q)editor}" )
  IFS= read -r -d '' file < <(
    setopt pipefail
    fd --type f --print0 ${=FD_OPTIONS} -- . "${1:-.}" |
      fzf --read0 --print0 --no-multi --preview 'bat --style=numbers --color=always --line-range=:300 -- {} 2>/dev/null || sed -n "1,160p" -- {}' --preview-window=right:60%
  ) && [[ -n $file ]] && command "${editor[@]}" -- "$file"
}

# Fuzzy-pick a file (with a preview) and cd into the directory containing it.
# Usage: fcd [directory]   (searches under the current directory by default)
fcd() {
  emulate -L zsh
  (( $# <= 1 )) || { print -u2 -- 'usage: fcd [directory]'; return 1; }
  local file
  IFS= read -r -d '' file < <(
    setopt pipefail
    fd --type f --print0 ${=FD_OPTIONS} -- . "${1:-.}" |
      fzf --read0 --print0 --no-multi --preview 'bat --style=numbers --color=always --line-range=:300 -- {} 2>/dev/null || sed -n "1,160p" -- {}' --preview-window=right:60%
  ) && [[ -n $file ]] && builtin cd -- "${file:h}"
}
