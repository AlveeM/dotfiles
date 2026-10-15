# Git abbreviations (zsh-abbr). Queued after the plugin loads, so `abbr` exists here.
# Session abbreviations (-S): defined on every startup, nothing is saved to disk.
# `%` marks where the cursor lands after expansion. Run `abbr -S list` to see what is defined.
#
# Scopes (one rule per form, so a name tells you where it expands):
#   abbr -S g=git            entry point
#   abbr -S git <n>=...      <n> in command position and after `git`; only for s and the
#                            conventional-commit shortcuts (c<type>, ac<type>)
#   abbr -S -g 'git <n>'=... only after `git`; used for everything else so names can't shadow commands
(( $+functions[abbr] )) || { print -u2 -- 'zsh: abbr unavailable; skipping abbreviations'; return 1 }
ABBR_QUIET=1
ABBR_SET_EXPANSION_CURSOR=1                                     # Off by default; makes `%` place the cursor

abbr -S g=git                                                   # Shorthand for git

abbr -S -g 'git aa'='git add --all'                             # Stage all changes

abbr -S -g 'git swc'='git switch -c'                            # Create and switch to a new branch
abbr -S -g 'git sw'='git switch'                                # Switch branches

abbr -S -g 'git cp'='git cherry-pick'                           # Cherry-pick a commit
abbr -S -g 'git cpa'='git cherry-pick --abort'                  # Abort a cherry-pick
abbr -S -g 'git cpc'='git cherry-pick --continue'               # Continue a cherry-pick
abbr -S -g 'git cps'='git cherry-pick --skip'                   # Skip the current cherry-pick

abbr -S -g 'git c'='git commit'                                 # Commit staged changes
abbr -S -g 'git m'='git commit -m "%"'                          # Commit with a message
abbr -S -g 'git am'='git commit -am "%"'                        # Stage tracked files and commit with a message
abbr -S -g 'git f'='git commit --fixup=%'                       # Create a fixup commit for a given commit
abbr -S -g 'git af'='git commit -a --fixup=%'                   # Stage tracked files and create a fixup commit
abbr -S -g 'git wip'='git commit -m "wip"'                      # Commit as work in progress

# Conventional commits: c<type> commits staged changes, ac<type> stages tracked files first.
abbr -S git cchore='commit -m "chore(%): %"'                    # Commit staged changes as chore(scope): message
abbr -S git acchore='commit -am "chore(%): %"'                  # Stage tracked files and commit as chore(scope): message
abbr -S git cdocs='commit -m "docs(%): %"'                      # Commit staged changes as docs(scope): message
abbr -S git acdocs='commit -am "docs(%): %"'                    # Stage tracked files and commit as docs(scope): message
abbr -S git cfeat='commit -m "feat(%): %"'                      # Commit staged changes as feat(scope): message
abbr -S git acfeat='commit -am "feat(%): %"'                    # Stage tracked files and commit as feat(scope): message
abbr -S git cfix='commit -m "fix(%): %"'                        # Commit staged changes as fix(scope): message
abbr -S git acfix='commit -am "fix(%): %"'                      # Stage tracked files and commit as fix(scope): message
abbr -S git crefactor='commit -m "refactor(%): %"'              # Commit staged changes as refactor(scope): message
abbr -S git acrefactor='commit -am "refactor(%): %"'            # Stage tracked files and commit as refactor(scope): message
abbr -S git cstyle='commit -m "style(%): %"'                    # Commit staged changes as style(scope): message
abbr -S git acstyle='commit -am "style(%): %"'                  # Stage tracked files and commit as style(scope): message
abbr -S git ctest='commit -m "test(%): %"'                      # Commit staged changes as test(scope): message
abbr -S git actest='commit -am "test(%): %"'                    # Stage tracked files and commit as test(scope): message

abbr -S -g 'git d'='git diff'                                   # Show unstaged changes

abbr -S -g 'git ma'='git merge --abort'                         # Abort a merge
abbr -S -g 'git mc'='git merge --continue'                      # Continue a merge
abbr -S -g 'git mn'='git merge --no-ff'                         # Merge, always creating a merge commit
abbr -S -g 'git mnn'='git merge --no-edit --no-ff'              # Merge with a merge commit and the default message

abbr -S -g 'git pl'='git pull'                                  # Pull from upstream
abbr -S -g 'git plf'='git pull --ff-only'                       # Pull from upstream with a fast-forward merge
abbr -S -g 'git p'='git push'                                   # Push to upstream

abbr -S -g 'git r'='git rebase'                                 # Rebase
abbr -S -g 'git rc'='git rebase --continue'                     # Continue a rebase
abbr -S -g 'git ra'='git rebase --abort'                        # Abort a rebase
abbr -S -g 'git rs'='git rebase --skip'                         # Skip the current rebase commit
abbr -S -g 'git riu'='git rebase -i --update-refs'              # Interactive rebase, updating stacked branch refs
abbr -S -g 'git ro'='git rebase --onto'                         # Rebase onto a new base
abbr -S -g 'git rebase -i u'='git rebase -i --update-refs'      # Interactive rebase, updating stacked branch refs
abbr -S -g 'git rebase i'='git rebase -i'                       # Interactive rebase
abbr -S -g 'git rebase o'='git rebase --onto'                   # Rebase onto a new base
abbr -S -g 'git rebase u'='git rebase --update-refs'            # Rebase, updating stacked branch refs

abbr -S -g 'git sp'='git stash pop'                             # Pop the latest stash
abbr -S git s='status'                                          # Show working tree status

# ================================================================================
# Carried over from my old aliases: only those with no equivalent above.
# Global-only (`g <n>`), since l/la/b would shadow aliases and commands.
# Dropped: git pf, git cm, greset (unguarded; use gpf, gm, gsync).
# Dropped as duplicates of defaults: gs->s gd->d gaa->aa gc->c gfix->f gco->sw gcp->cp gpop->sp
# Renamed: git co->sw and git ch->swc (checkout -> switch).
# Renamed from the g-prefixed top-level form: gap->g ap, gca->g ca, gl->g l, gla->g la,
# gg->g g, glf->g lf, gb->g b, gsq->g sq, gundo->g undo, grh->g rh;
# top-level merge/pull/push dropped (use g mn / g pl / g p).
# ================================================================================
abbr -S -g 'git ap'='git add -p'                                # Interactively stage changes
abbr -S -g 'git ca'='git commit --amend --no-edit'              # Amend last commit without changing message
abbr -S -g 'git l'='git log --oneline -10'                      # Recent commits
abbr -S -g 'git la'='git log --oneline --all -10'               # All branches
abbr -S -g 'git g'='git log --graph --oneline --decorate --all' # Commit graph for all branches
abbr -S -g 'git lf'='git log --oneline | fzf'                   # Browse commit history interactively (requires fzf)
abbr -S -g 'git b'='git branch -vv'                             # List branches with tracking info
abbr -S -g 'git sq'='git rebase -i --autosquash'                # Interactive rebase with automatic squashing
abbr -S -g 'git undo'='git reset --soft HEAD~1'                 # Undo last commit, keep changes staged
abbr -S -g 'git rh'='git reset HEAD~1'                          # Undo last commit, keep changes unstaged
