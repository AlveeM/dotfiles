# Audit permissions and rebuild the dump only when inputs change.
_zsh_init_completion() {
  emulate -L zsh
  zmodload zsh/stat || return 1
  autoload -Uz compinit compaudit

  local dump="${ZDOTDIR:-$HOME}/.zcompdump-$ZSH_VERSION"
  local inputs="$dump.inputs" dir signature="$ZSH_VERSION"
  local -A metadata

  # Directory mtimes detect additions/removals; rebuild-completions covers
  # in-place edits to completion declarations that do not change these mtimes.
  for dir in "${fpath[@]}" "$HOME/.zsh/plugins/plugins.zsh" "$HOME/.zsh/plugins/plugins.lock"; do
    if zstat -H metadata +mtime -- "$dir" 2>/dev/null; then
      signature+=$'\n'"$dir:$metadata[mtime]"
    else
      signature+=$'\n'"$dir:missing"
    fi
  done
  # Audit on every startup: permissions and ownership can change without
  # changing directory mtimes. Only use -C after a successful current audit.
  if [[ -r $inputs && -s $dump && "$(<$inputs)" == "$signature" ]] &&
      compaudit >/dev/null 2>&1; then
    # Unchanged, currently secure inputs: reuse the completion dump.
    compinit -C -d "$dump" || return 1
  else
    command rm -f -- "$dump" "$dump.zwc" || return 1
    # -i audits and excludes insecure paths without prompting.
    unset _comp_secure
    compinit -i -d "$dump" || return 1
    [[ ${_comp_secure:-} != yes ]] ||
      print -u2 -- 'zsh: insecure completion paths were excluded; run compaudit for details'
    print -r -- "$signature" >| "$inputs"
  fi
  typeset -gA _zsh_file_completions
  _zsh_file_completions=( "${(@kv)_comps}" )
}

rebuild-completions() {
  emulate -L zsh
  local dump="${ZDOTDIR:-$HOME}/.zcompdump-$ZSH_VERSION"
  command rm -f -- "$dump" "$dump.zwc" "$dump.inputs" || return 1
  # Keep registrations added by tool initialization after compinit, while
  # dropping old file mappings so renamed #compdef declarations take effect.
  local key
  local -A runtime_completions
  for key in "${(@k)_comps}"; do
    if [[ ${_comps[$key]} != ${_zsh_file_completions[$key]-} ]]; then
      runtime_completions[$key]=${_comps[$key]}
    fi
  done
  _comps=()
  _zsh_init_completion || return 1
  _comps+=( "${(@kv)runtime_completions}" )
}

_zsh_init_completion || return 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
# Empty list-colors uses zsh's default colors; LS_COLORS is unset on macOS.
zstyle ':completion:*' list-colors ''
