# Git abbreviations (zsh-abbr). Queued after the plugin loads, so `abbr` exists here.
# Session abbreviations (-S): defined on every startup, nothing is saved to disk.
# In zsh-abbr, `abbr git <name>=...` defines `<name>` in command position and `git <name>`
# after git; `%` marks where the cursor lands after expansion.
(( $+functions[abbr] )) || { print -u2 -- 'zsh: abbr unavailable; skipping abbreviations'; return 1 }
ABBR_QUIET=1

# ================================================================================
# Defaults from https://olets.dev/posts/the-command-line-mostly-git-abbreviations-i-rely-on/
# Differences from the post: duplicate/malformed rows are dropped, `git cp` and `git mc`
# are global-only so they don't shadow cp and Midnight Commander.
# ================================================================================

abbr -S g=git

abbr -S git aa="add --all"

abbr -S git ch="checkout -b"
abbr -S git cm="checkout main"
abbr -S git co="checkout"

abbr -S -g "git cp"="git cherry-pick"
abbr -S git cpa='cherry-pick --abort'
abbr -S git cpc='cherry-pick --continue'
abbr -S git cps='cherry-pick --skip'

abbr -S git c=commit
abbr -S git m='commit -m "%"'
abbr -S git am='commit -am "%"'
abbr -S git f="commit --fixup=%"
abbr -S git af="commit -a --fixup=%"
abbr -S git wip='commit -m "wip"'

abbr -S git achore='commit -am "chore(%): %"'
abbr -S git chore='commit -m "chore(%): %"'
abbr -S git adocs='commit -am "docs(%): %"'
abbr -S git docs='commit -m "docs(%): %"'
abbr -S git afeat='commit -am "feat(%): %"'
abbr -S git feat='commit -m "feat(%): %"'
abbr -S git afix='commit -am "fix(%): %"'
abbr -S git fix='commit -m "fix(%): %"'
abbr -S git arefactor='commit -am "refactor(%): %"'
abbr -S git refactor='commit -m "refactor(%): %"'
abbr -S git astyle='commit -am "style(%): %"'
abbr -S git style='commit -m "style(%): %"'
abbr -S git atests='commit -am "tests(%): %"'
abbr -S git tests='commit -m "tests(%): %"'

abbr -S git d=diff

abbr -S git ma='merge --abort'
abbr -S -g "git mc"="git merge --continue"
abbr -S git mn='merge --no-ff'
abbr -S git mnn='merge --no-edit --no-ff'
abbr -S merge='git merge'

abbr -S pull="git pull"

abbr -S git p=push
abbr -S git pf='push --force-with-lease'
abbr -S push="git push"

abbr -S gr='git rebase'
abbr -S -g 'git r'='git rebase'
abbr -S git rc="git rebase --continue"
abbr -S git ra="git rebase --abort"
abbr -S git rs="git rebase --skip"
abbr -S git riu="git rebase -i --update-refs"
abbr -S git ro="git rebase --onto"
abbr -S -g "git rebase s"="git rebase --skip"
abbr -S -g 'git rebase --update-refs i'='git rebase --update-refs -i'
abbr -S -g 'git rebase -i u'='git rebase -i --update-refs'
abbr -S -g 'git rebase i'='git rebase -i'
abbr -S -g 'git rebase o'='git rebase --onto'
abbr -S -g 'git rebase u'='git rebase --update-refs'

abbr -S git sp='stash pop'
abbr -S git s=status

# ================================================================================
# Carried over from the old aliases: only those with no equivalent above.
# Dropped as duplicates of defaults: gs->s gd->d gaa->aa gc->c gfix->f gco->co gcp->cp gpop->sp
# ================================================================================
abbr -S gap='git add -p'                               # Interactively stage changes
abbr -S gca='git commit --amend --no-edit'             # Amend last commit without changing message
abbr -S gl='git log --oneline -10'                     # Recent commits
abbr -S gla='git log --oneline --all -10'              # All branches
abbr -S gg='git log --graph --oneline --decorate --all' # Commit graph for all branches
abbr -S glf='git log --oneline | fzf'                  # Browse commit history interactively (requires fzf)
abbr -S gb='git branch -vv'                            # List branches with tracking info
abbr -S gsq='git rebase -i --autosquash'               # Interactive rebase with automatic squashing
abbr -S gundo='git reset --soft HEAD~1'                # Undo last commit, keep changes staged
abbr -S grh='git reset HEAD~1'                         # Undo last commit, keep changes unstaged
abbr -S greset='git reset --hard HEAD'                 # Reset to last commit, discard all changes
