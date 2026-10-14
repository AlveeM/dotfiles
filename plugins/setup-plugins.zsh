#!/bin/zsh
# Explicit installation/update: edit the pin: SHAs in plugins/plugins.txt, then run this script.
# No plugin installation occurs at shell startup.
emulate -R zsh
setopt err_exit pipefail extendedglob

# Antidote cannot pin itself, so it is the one checkout this script pins directly.
antidote_url=https://github.com/mattmc3/antidote.git
antidote_sha=9bb69ab99c6f05d6e6ae237f7ce222eeeb5b4a14 # v2.3.0

setup_plugins=${0:A:h}
setup_lock="$setup_plugins/.setup-lock"
setup_temp=''
if ! mkdir "$setup_lock" 2>/dev/null; then
  print -u2 -- "Plugin setup already running, or lock remains: $setup_lock"
  exit 1
fi
trap '[[ -z $setup_temp ]] || rm -f -- "$setup_temp"; rmdir -- "$setup_lock"' EXIT

export ANTIDOTE_HOME="$HOME/.cache/antidote"

# Validate plugins.txt: GitHub owner/repo shorthand only, always pinned to a full SHA.
typeset -A setup_pins
while read -r setup_entry setup_rest; do
  [[ -z $setup_entry || $setup_entry == \#* ]] && continue
  setup_repo=${setup_entry#preset:}
  setup_words=( ${=setup_rest} )
  setup_sha=${${(M)setup_words:#pin:*}[1]#pin:}
  if [[ $setup_repo != [A-Za-z0-9._-]##/[A-Za-z0-9._-]## ||
        $setup_sha != [0-9a-f](#c40) ]]; then
    print -u2 -- "Invalid plugins.txt entry: $setup_entry $setup_rest"
    exit 1
  fi
  setup_pins[$setup_repo]=$setup_sha
done < "$setup_plugins/plugins.txt"
(( $#setup_pins )) || { print -u2 -- 'plugins.txt has no entries'; exit 1; }

# Pin Antidote itself.
setup_antidote="$setup_plugins/antidote"
if [[ ! -e $setup_antidote ]]; then
  mkdir -p -- "$setup_plugins"
  git init -q -- "$setup_antidote"
  git -C "$setup_antidote" remote add origin "$antidote_url"
fi
if [[ $(git -C "$setup_antidote" rev-parse --show-toplevel) != ${setup_antidote:A} ||
      $(git -C "$setup_antidote" remote get-url origin) != $antidote_url ]]; then
  print -u2 -- "Unexpected repository or remote: $setup_antidote"
  exit 1
fi
if [[ -n $(git -C "$setup_antidote" status --porcelain) ]]; then
  print -u2 -- "Refusing to overwrite local changes: $setup_antidote"
  exit 1
fi
if ! git -C "$setup_antidote" cat-file -e "$antidote_sha^{commit}" 2>/dev/null; then
  git -C "$setup_antidote" fetch --depth=1 origin "$antidote_sha"
fi
git -C "$setup_antidote" -c advice.detachedHead=false checkout -q --detach "$antidote_sha"
print -r -- "Pinned antidote to $antidote_sha"

source "$setup_antidote/antidote.zsh"
# Antidote leaves a half-switched checkout when a pin moves under local edits.
# `antidote path` finds existing clones whichever path style they were made with.
for setup_repo in ${(k)setup_pins}; do
  setup_dir=$(antidote path "$setup_repo" 2>/dev/null) || continue
  if [[ -e $setup_dir && -n $(git -C "$setup_dir" status --porcelain) ]]; then
    print -u2 -- "Refusing to overwrite local changes: $setup_dir"
    exit 1
  fi
done

# Clone/checkout the pinned plugins and generate the static loader.
setup_temp=$(mktemp "$setup_plugins/plugins.zsh.XXXXXX")
antidote bundle < "$setup_plugins/plugins.txt" >| "$setup_temp"
[[ -s $setup_temp ]]
zsh -f -n "$setup_temp"
# antidote can report a failed clone or checkout and still exit 0, so check every pin.
for setup_repo setup_sha in ${(kv)setup_pins}; do
  setup_head=$(git -C "$(antidote path "$setup_repo")" rev-parse HEAD)
  if [[ $setup_head != $setup_sha ]]; then
    print -u2 -- "$setup_repo is at $setup_head, expected $setup_sha"
    exit 1
  fi
  print -r -- "Pinned ${setup_repo:t} to $setup_sha"
done
mv -f -- "$setup_temp" "$setup_plugins/plugins.zsh"
setup_temp=''
# Do not let a previously compiled loader shadow the new one.
rm -f -- "$setup_plugins/plugins.zsh.zwc"
print -r -- 'Plugin setup complete. Open a new shell to load it.'
