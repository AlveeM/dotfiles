# ================================================================================
# Lazily initialized tools installed outside mise (conda, gcloud)
# conda and the gcloud PATH hook are guarded by file checks; the gcloud wrapper is not.
# ================================================================================

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
