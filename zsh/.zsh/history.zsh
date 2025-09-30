# Advanced ZSH History Configuration for Multiple Terminals & Tmux

# === Core History Settings ===
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000                    # Memory buffer (5x increase)
export SAVEHIST=100000                   # Disk storage (10x increase)
export HISTFILESIZE=100000              # Ensure file can grow

# === History Writing Options ===
# SHARE_HISTORY causes arrow key issues in tmux - use APPEND_HISTORY instead
unsetopt SHARE_HISTORY                 # Don't share history in real-time (causes ZLE issues)
setopt APPEND_HISTORY                  # Append to history file on shell exit
setopt INC_APPEND_HISTORY              # Write immediately (without SHARE_HISTORY side effects)
setopt EXTENDED_HISTORY                # Record timestamp of command (":start:elapsed;command")

# === Intelligent Deduplication ===
setopt HIST_EXPIRE_DUPS_FIRST          # Expire duplicates first when trimming
setopt HIST_IGNORE_DUPS                # Don't record if same as previous
setopt HIST_IGNORE_ALL_DUPS            # Delete old recorded entry if duplicate
setopt HIST_FIND_NO_DUPS               # Don't display duplicates in searches
setopt HIST_SAVE_NO_DUPS               # Don't write duplicates to file

# === History Quality Improvements ===
setopt HIST_REDUCE_BLANKS              # Remove superfluous blanks
setopt HIST_VERIFY                     # Don't execute immediately on expansion
setopt HIST_BEEP                       # Beep when accessing non-existent history
setopt HIST_NO_STORE                   # Don't store 'history' or 'fc' commands
setopt HIST_IGNORE_SPACE              # Commands starting with space aren't recorded

# === History Protection ===
setopt HIST_FCNTL_LOCK                 # Use fcntl for locking (better for NFS)
setopt HIST_LEX_WORDS                  # Better word splitting for history


# === Improved FZF History Search ===
__fzf_history_advanced__() {
    local selected
    # Parse extended history format correctly: ": timestamp:duration;command"
    # fc -rl 1 gives reverse order (newest first), which is what we want
    selected=$(fc -rl 1 |
        sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' |
        awk '!seen[$0]++' |
        fzf --query="$LBUFFER" \
            --no-sort \
            --exact)

    if [[ -n "$selected" ]]; then
        LBUFFER=$selected
    fi
    zle reset-prompt
}

# Replace the basic fzf history binding
zle -N __fzf_history_advanced__
bindkey '^R' __fzf_history_advanced__

# Ensure arrow keys work properly (explicit bindings)
# Just for test 
# bindkey '^[[A' up-line-or-history      # Up arrow
# bindkey '^[[B' down-line-or-history    # Down arrow
# bindkey '^[OA' up-line-or-history      # Up arrow (alternative)
# bindkey '^[OB' down-line-or-history    # Down arrow (alternative)

# === Tmux Integration ===
# With INC_APPEND_HISTORY, each shell writes immediately to disk
# New shells/panes automatically get the full history on startup
# No aggressive syncing needed - keeps arrow keys working smoothly

# === Aliases for History Management ===
alias h='history'

# === Per-Directory History (Optional) ===
# Uncomment to enable project-specific history
# per_directory_history() {
#     local project_root=$(git rev-parse --show-toplevel 2>/dev/null)
#     if [[ -n "$project_root" ]]; then
#         export HISTFILE="$project_root/.zsh_history_local"
#         fc -R  # Reload from new histfile
#     fi
# }
# chpwd_functions+=(per_directory_history)
