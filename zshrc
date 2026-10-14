# Keep PATH/fpath free of duplicates (nested shells, re-sourcing).
typeset -U path fpath

# Required modules report missing files and load failures once.
# Stays defined after startup: the deferred keybindings load below calls it.
_zsh_source_required() {
  if [[ ! -r $1 ]]; then
    print -u2 -- "zsh: required configuration unavailable: $1"
    return 1
  fi
  source "$1" || {
    print -u2 -- "zsh: configuration loading failed: $1"
    return 1
  }
}

# Establish PATH and environment before initializing tools.
for _zsh_config in path exports history aliases functions git; do
  _zsh_source_required "$HOME/.zsh/zsh.d/$_zsh_config.zsh"
done
unset _zsh_config

# Work-only additions (written by the internal work dotfiles repo); absent on other machines.
[[ -r "$HOME/.zshrc.work" ]] && source "$HOME/.zshrc.work"

# Install/update pinned plugins explicitly: zsh ~/.zsh/plugins/setup-plugins.zsh
# Edit plugins.txt or plugins.lock, then run setup to regenerate plugins.zsh.
# The generated plugins.zsh is static; only setup needs Antidote itself.
if [[ -r "$HOME/.zsh/plugins/plugins.zsh" ]]; then
  # Debug startup with: ZSH_CONFIG_DEBUG=1 zsh
  # Preserve the generated loader; disable deferred stderr suppression while
  # it queues work, then restore the original zsh-defer implementation below.
  if [[ ${ZSH_CONFIG_DEBUG:-0} == 1 ]]; then
    # Load zsh-defer from the same path the generated loader uses.
    _zsh_defer_source=( ${(M)${(f)"$(<$HOME/.zsh/plugins/plugins.zsh)"}:#*source *zsh-defer.plugin.zsh*} )
    _zsh_defer_source=${(Q)${_zsh_defer_source[1]#*source }}
    _zsh_defer_source=${_zsh_defer_source/#\$HOME/$HOME}
    if [[ -n $_zsh_defer_source ]]; then
      _zsh_source_required "$_zsh_defer_source"
    else
      print -u2 -- 'zsh: zsh-defer source not found in plugins.zsh'
    fi
    unset _zsh_defer_source
    if (( $+functions[zsh-defer] )); then
      functions[_zsh_config_original_defer]=$functions[zsh-defer]
      zsh-defer() { _zsh_config_original_defer -2 "$@"; }
    fi
  fi
  source "$HOME/.zsh/plugins/plugins.zsh" || print -u2 -- 'zsh: plugin loading failed; run zsh ~/.zsh/plugins/setup-plugins.zsh'
else
  print -u2 -- 'zsh: plugins unavailable; run zsh ~/.zsh/plugins/setup-plugins.zsh'
fi

# Queue bindings after the deferred history search plugin.
if (( $+functions[zsh-defer] )); then
  zsh-defer _zsh_source_required "$HOME/.zsh/zsh.d/keybindings.zsh"
elif (( $+functions[history-substring-search-up] )); then
  _zsh_source_required "$HOME/.zsh/zsh.d/keybindings.zsh"
fi

# Completion runs after plugins add their directories to fpath.
if (( $+functions[_zsh_config_original_defer] )); then
  functions[zsh-defer]=$functions[_zsh_config_original_defer]
  unfunction _zsh_config_original_defer
fi
_zsh_source_required "$HOME/.zsh/zsh.d/completion.zsh"

# Cache generated init code, regenerating when the resolved binary changes
# (e.g. a Homebrew upgrade). Sets REPLY to the cache file; callers source it
# at top level so the init code's variables are not function-local.
# Each writer validates its own temporary file before atomic publication.
_zsh_cached_init() {
  local tool=$1 bin=$commands[$1] header line temporary
  shift
  if [[ -z $bin ]]; then
    print -u2 -- "zsh: $tool unavailable; skipping initialization"
    return 1
  fi
  REPLY="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$tool-init.zsh"
  header="# ${bin:A} $*"
  [[ -s $REPLY && $REPLY -nt $bin ]] && IFS= read -r line < "$REPLY"
  [[ $line == $header ]] && return 0
  {
    command mkdir -p -- "${REPLY:h}" &&
      temporary=$(command mktemp "${REPLY}.XXXXXX") &&
      { print -r -- "$header" && command "$tool" "$@"; } >| "$temporary" &&
      command zsh -f -n "$temporary" &&
      command mv -f -- "$temporary" "$REPLY"
  } || {
    [[ -z $temporary ]] || command rm -f -- "$temporary"
    print -u2 -- "zsh: $tool initialization code could not be generated"
    return 1
  }
}
_zsh_cached_init starship init zsh --print-full-init && source "$REPLY"
_zsh_cached_init zoxide init zsh && source "$REPLY"
_zsh_cached_init fzf --zsh && source "$REPLY"
unfunction _zsh_cached_init

# Activate mise last in the synchronous startup sequence. Not cached: its
# output embeds a snapshot of the current PATH.
if (( ! $+commands[mise] )); then
  print -u2 -- 'zsh: mise unavailable; skipping initialization'
elif _zsh_init_code=$(command mise activate zsh); then
  eval "$_zsh_init_code" || print -u2 -- 'zsh: mise initialization failed'
else
  print -u2 -- 'zsh: mise initialization code could not be generated'
fi
unset _zsh_init_code
