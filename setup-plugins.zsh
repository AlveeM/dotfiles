#!/bin/zsh
# Explicit installation/update: edit plugins.lock, then run this script.
# Existing checkouts must be clean. No plugin installation occurs at startup.
emulate -R zsh
setopt err_exit pipefail extendedglob

setup_root=${0:A:h}
setup_lock="$setup_root/plugins/.setup-lock"
setup_temp=''
if ! mkdir "$setup_lock" 2>/dev/null; then
  print -u2 -- "Plugin setup already running, or lock remains: $setup_lock"
  exit 1
fi
trap '[[ -z $setup_temp ]] || rm -f -- "$setup_temp"; rmdir -- "$setup_lock"' EXIT

while read -r setup_url setup_revision setup_relative; do
  [[ -z $setup_url || $setup_url == \#* ]] && continue
  if [[ $setup_url != https://github.com/*.git ||
        $setup_revision != [0-9a-f](#c40) ||
        $setup_relative == /* || $setup_relative == *..* || -z $setup_relative ]]; then
    print -u2 -- 'Invalid plugins.lock entry'
    exit 1
  fi
  setup_repo="$HOME/$setup_relative"
  if [[ ! -e $setup_repo ]]; then
    mkdir -p -- "${setup_repo:h}"
    git init -q -- "$setup_repo"
    git -C "$setup_repo" remote add origin "$setup_url"
  fi
  setup_existing_root=$(git -C "$setup_repo" rev-parse --show-toplevel)
  setup_existing_url=$(git -C "$setup_repo" remote get-url origin)
  # git reports the symlink-resolved toplevel, so compare against the resolved path
  # (a $HOME reached through a symlink would otherwise never match).
  if [[ $setup_existing_root != ${setup_repo:A} ||
        ${setup_existing_url%.git} != ${setup_url%.git} ]]; then
    print -u2 -- "Unexpected repository or remote: $setup_repo"
    exit 1
  fi
  if [[ -n $(git -C "$setup_repo" status --porcelain) ]]; then
    print -u2 -- "Refusing to overwrite local changes: $setup_repo"
    exit 1
  fi
  if ! git -C "$setup_repo" cat-file -e "$setup_revision^{commit}" 2>/dev/null; then
    git -C "$setup_repo" fetch --depth=1 origin "$setup_revision"
  fi
  git -C "$setup_repo" -c advice.detachedHead=false checkout -q --detach "$setup_revision"
  print -r -- "Pinned ${setup_url:t:r} to $setup_revision"
done < "$setup_root/plugins/plugins.lock"

source "$setup_root/plugins/antidote/antidote.zsh"
# Keep the implicit defer dependency on its pinned local checkout too.
zstyle ':antidote:defer' bundle "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-defer"
setup_temp=$(mktemp "$setup_root/plugins/plugins.zsh.XXXXXX")
antidote bundle < "$setup_root/plugins/plugins.txt" >| "$setup_temp"
[[ -s $setup_temp ]]
zsh -f -n "$setup_temp"
mv -f -- "$setup_temp" "$setup_root/plugins/plugins.zsh"
setup_temp=''
# Do not let a previously compiled loader shadow the new one.
rm -f -- "$setup_root/plugins/plugins.zsh.zwc"
print -r -- 'Plugin setup complete. Open a new shell to load it.'
