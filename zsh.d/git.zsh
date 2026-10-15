# ================================================================================
# Helper functions
# ================================================================================
_zsh_git_main() {
  local ref main
  ref=$(git symbolic-ref --quiet refs/remotes/origin/HEAD) || {
    print -u2 -- 'Cannot resolve origin/HEAD; set it with git remote set-head origin -a.'
    return 1
  }
  [[ $ref == refs/remotes/origin/* ]] || return 1
  main=${ref#refs/remotes/origin/}
  [[ -n $main ]] && git show-ref --verify --quiet "refs/remotes/origin/$main" || {
    print -u2 -- 'origin/HEAD does not point to an available remote branch.'
    return 1
  }
  print -r -- "$main"
}

_zsh_git_branch() {
  git symbolic-ref --quiet --short HEAD || {
    print -u2 -- 'This operation requires an attached branch in a Git repository.'
    return 1
  }
}

# ================================================================================
# Branch management
# ================================================================================
# requires fzf
# Remove the old alias when this module is re-sourced in an existing shell.
unalias gbf 2>/dev/null
gbf() {
  emulate -L zsh -o pipefail
  local branch
  branch=$(git branch --format='%(refname:short)' | fzf --no-multi) || return
  [[ -n $branch ]] || return 1
  git switch -- "$branch"
}

# Delete branches interactively (fzf multi-select), with confirmation
gbd() {
  emulate -L zsh -o pipefail
  local selection reply
  local -a branches
  selection=$(git branch --format='%(refname:short)' | fzf --multi) || return
  [[ -n $selection ]] || return 1
  branches=( "${(@f)selection}" )
  print -r -- "⚠️ Force deleting: ${(j: :)branches}"
  read -r 'reply?Continue? [y/N] ' || return 1
  [[ $reply == [Yy] ]] || return 1
  git branch -D -- "${branches[@]}"
}


# Switch to main branch
gm() {
  local main
  main=$(_zsh_git_main) || return 1
  git switch -- "$main"
}

# Creates and checks out a new branch with your username as a prefix
gcb() {
  emulate -L zsh
  [[ $# == 1 && -n $1 ]] || { print -u2 -- 'usage: gcb <branch>'; return 1; }
  local username branch_name
  username=$(whoami) || return 1
  branch_name="$username/$1"
  git check-ref-format --branch "$branch_name" >/dev/null || {
    print -u2 -- "Invalid branch name: $branch_name"
    return 1
  }
  git checkout -b "$branch_name"
}

# ================================================================================
# Remote operations - syncing with remote repositories
# ================================================================================

# Fetches the current branch from origin with pruning and error handling
gf() {
  local b
  b=$(_zsh_git_branch) || return 1
  git fetch origin "+refs/heads/$b:refs/remotes/origin/$b" || {
    print -u2 -- 'Failed to fetch. Check network/remote.'
    return 1
  }
}

# Shows the diff between the current branch and the latest main branch from origin
gdm() {
  local main
  main=$(_zsh_git_main) || return 1
  git fetch origin "+refs/heads/$main:refs/remotes/origin/$main" &&
    git diff "origin/$main" --
}

# Pushes the current branch and creates a draft PR, with protection against pushing from main
gpu() {
  local b main
  b=$(_zsh_git_branch) || return 1
  main=$(_zsh_git_main) || return 1
  [[ $b != main && $b != master && $b != $main ]] || {
    print -u2 -- "Don't push from the main branch."
    return 1
  }
  git push -u origin "$b" && gh pr create -d -f
}

# Push one explicit upstream ref, with a lease captured before confirmation.
gpf() {
  emulate -L zsh
  local b current reply upstream remote destination tracking expected head
  local -a fields
  b=$(_zsh_git_branch) || return 1
  upstream=$(git for-each-ref --format='%(upstream:remotename)%09%(upstream:remoteref)%09%(upstream)' "refs/heads/$b") || return 1
  fields=( "${(@s:	:)upstream}" )
  [[ $#fields == 3 && -n $fields[1] && $fields[2] == refs/heads/* && -n $fields[3] ]] || {
    print -u2 -- 'This operation requires a configured upstream branch.'
    return 1
  }
  remote=$fields[1]
  destination=$fields[2]
  tracking=$fields[3]
  expected=$(git rev-parse --verify "$tracking^{commit}") || return 1
  head=$(git rev-parse --verify "refs/heads/$b^{commit}") || return 1
  print -r -- "⚠️ Force pushing $b to $remote/${destination#refs/heads/}"
  print -r -- "Expected destination commit: $expected"
  read -r 'reply?Continue? [y/N] ' || return 1
  [[ $reply == [Yy] ]] || return 1
  current=$(_zsh_git_branch) || return 1
  [[ $current == $b ]] || { print -u2 -- 'Branch changed; aborting.'; return 1; }
  git push "--force-with-lease=$destination:$expected" -- "$remote" "$head:$destination"
}

# ================================================================================
# Advanced workflows - rebasing, stashing, and interactive operations
# ================================================================================

# Rebases the current branch onto the latest version of the main branch
grm() {
  local main cur
  main=$(_zsh_git_main) || return 1
  cur=$(_zsh_git_branch) || return 1
  git fetch origin "+refs/heads/$main:refs/remotes/origin/$main" &&
    git rebase "origin/$main" "$cur"
}

# Moves the last N commits of the current branch onto the latest origin main branch
gcr() {
  local n=${1:-} main cur
  [[ $# == 1 && $n == <1-> ]] || { print -u2 -- 'usage: gcr <positive commit count>'; return 1; }
  main=$(_zsh_git_main) || return 1
  cur=$(_zsh_git_branch) || return 1
  git rev-parse --verify "$cur~$n^{commit}" >/dev/null || return 1
  git fetch origin "+refs/heads/$main:refs/remotes/origin/$main" &&
    git rebase --onto "origin/$main" "$cur~$n" "$cur"
}

# ================================================================================
# Reset & undo operations - undoing changes (use with caution)
# ================================================================================

# Intentional reset workflow: stash tracked/untracked changes, excluding ignored
# files. No backup branch is created; discarded commits may require the reflog.
gsync() {
  local b current reply
  b=$(_zsh_git_branch) || return 1
  print -r -- "⚠️ This will reset branch '$b' to origin/$b after stashing tracked and untracked changes."
  print -r -- 'Ignored files are not backed up and may be overwritten by incoming tracked paths.'
  print -r -- 'No backup branch is created; discarded unpushed commits may require reflog recovery.'
  read -r 'reply?Continue? [y/N] ' || return 1
  [[ $reply == [Yy] ]] || return 1
  current=$(_zsh_git_branch) || return 1
  [[ $current == $b ]] || { print -u2 -- 'Branch changed; aborting.'; return 1; }
  git fetch --prune origin "+refs/heads/$b:refs/remotes/origin/$b" || return 1
  git stash push --include-untracked -m "gsync backup $(date)" || {
    print -u2 -- 'Backup failed; aborting reset.'
    return 1
  }
  current=$(_zsh_git_branch) || return 1
  [[ $current == $b ]] || { print -u2 -- 'Branch changed; aborting reset.'; return 1; }
  git reset --hard "origin/$b"
}

# ================================================================================
# Cleanup & Maintenance - branch hygiene and repository cleanup
# ================================================================================
# Delete a remote branch with confirmation
gdr() {
  emulate -L zsh
  [[ $# == 1 && -n $1 && $1 != -* ]] || { print -u2 -- 'usage: gdr <branch>'; return 1; }
  local b=$1 reply
  print -r -- "⚠️ Deleting remote branch '$b'"
  read -r 'reply?Continue? [y/N] ' || return 1
  [[ $reply == [Yy] ]] || return 1
  git push origin --delete -- "refs/heads/$b"
}

# Delete gone-upstream branches without interpreting quotes or backslashes.
_zsh_prune_gone_branches() {
  emulate -L zsh
  local mode=$1 listing branch state
  local -a branches
  git fetch -p || return
  listing=$(git for-each-ref --format='%(refname:short)%09%(upstream:track)' refs/heads/) || return
  while IFS=$'\t' read -r branch state; do
    [[ $state == '[gone]' ]] && branches+=( "$branch" )
  done <<< "$listing"
  (( $#branches )) || return 0
  if [[ $mode == -D ]]; then
    local reply
    print -r -- "⚠️ Force deleting branches (may lose unmerged work): ${(j: :)branches}"
    read -r 'reply?Continue? [y/N] ' || return 1
    [[ $reply == [Yy] ]] || return 1
  fi
  git branch "$mode" -- "${branches[@]}"
}

# Removes local branches whose remote counterparts have been deleted.
gpurge() {
  _zsh_prune_gone_branches -d
}

# Force-deletes local branches whose remote counterparts have been deleted.
gpurgef() {
  _zsh_prune_gone_branches -D
}
