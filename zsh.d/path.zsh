# ================================================================================
# PATH and tool initialization (Go, conda, gcloud)
# NOTE: `mise activate` stays in .zshrc and must run last.
# ================================================================================

# Go
export PATH="$PATH:$HOME/go/bin"  # static $(go env GOPATH)/bin to avoid a subprocess at startup

# >>> conda initialize (lazy) >>>
# Defer the ~74ms `conda shell.zsh hook` until conda is actually used.
if [[ -x "$HOME/anaconda3/bin/conda" ]]; then
conda() {
  local __conda_setup
  unset -f conda
  __conda_setup="$("$HOME/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/anaconda3/bin:$PATH"
  fi
  unset __conda_setup
  conda "$@"
}
fi
# <<< conda initialize (lazy) <<<

# Updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# Explicit performance choice: load SDK completion only after executing gcloud.
# Tab completion before its first execution intentionally does not load the SDK.
gcloud() {
  unset -f gcloud
  [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"
  command gcloud "$@"
}

# mise shims go last so already-installed system tools win until mise provides them;
# `mise activate` (end of .zshrc) later puts real tool paths first. The shims make mise-managed
# tools (starship, zoxide, fzf, ...) resolvable for the cached inits earlier in .zshrc.
export PATH="$HOME/.local/bin:$PATH:$HOME/.local/share/mise/shims"
