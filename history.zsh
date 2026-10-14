# ================================================================================
# zsh History Config
# ================================================================================
# Where history is stored
HISTFILE=~/.zsh_history

# Big, but not absurd (tweak as you like)
HISTSIZE=250000
SAVEHIST=200000

# History behavior
setopt APPEND_HISTORY          # don't overwrite history file
setopt SHARE_HISTORY           # share history across sessions (implies incremental append)

# Reduce duplicates
setopt HIST_IGNORE_ALL_DUPS    # remove older duplicate entries when a new one is added
setopt HIST_FIND_NO_DUPS       # when searching, skip duplicates
setopt HIST_SAVE_NO_DUPS       # don't write duplicates to the history file
setopt HIST_EXPIRE_DUPS_FIRST  # trim duplicates first when HISTSIZE exceeds SAVEHIST

# Ignore “unimportant” commands
setopt HIST_IGNORE_SPACE       # commands starting with a space aren't saved
setopt HIST_REDUCE_BLANKS      # remove extra blanks before saving

# Better multi-session behavior
setopt EXTENDED_HISTORY        # add timestamps; shared entries may lack final durations
