# Advanced ZSH History Configuration for Multiple Terminals & Tmux

# === Core History Settings ===
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000                    # Memory buffer (5x increase)
export SAVEHIST=100000                   # Disk storage (10x increase)
export HISTFILESIZE=100000              # Ensure file can grow

# === Immediate History Sharing (Critical for tmux) ===
setopt SHARE_HISTORY                    # Share history between all sessions
setopt INC_APPEND_HISTORY_TIME         # Write after each command with timestamp
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

# === Enhanced History Functions ===

# Backup history periodically (call from cron or manually)
history_backup() {
    local backup_dir="$HOME/.zsh_history_backups"
    mkdir -p "$backup_dir"
    cp "$HISTFILE" "$backup_dir/zsh_history_$(date +%Y%m%d_%H%M%S).bak"
    # Keep only last 30 backups
    ls -t "$backup_dir"/zsh_history_*.bak | tail -n +31 | xargs -r rm
}

# Merge history from all tmux panes/windows
history_sync() {
    fc -RI  # Read history from file, Import new entries
    fc -W   # Write current history to file
}

# Clean duplicate entries from history file
history_dedupe() {
    local temp_file=$(mktemp)
    # Preserve timestamps while removing duplicates
    awk -F';' '!seen[$2]++ {print}' "$HISTFILE" > "$temp_file"
    mv "$temp_file" "$HISTFILE"
    fc -R  # Reload history
}

# Better history statistics
history_stats() {
    fc -l 1 | \
    awk '{CMD[$2]++; count++} END {
        for (cmd in CMD) {
            printf "%7d %7.2f%% %s\n", CMD[cmd], CMD[cmd]/count*100, cmd
        }
    }' | sort -rn | head -20
}

# === Improved FZF History Search ===
__fzf_history_advanced__() {
    local selected
    # Use extended history format, remove duplicates, preserve timestamp info
    selected=$(fc -rli 1 |
        awk '!seen[$4]++ && NF>3 {$1=$2=$3=""; print substr($0,4)}' |
        fzf --query="$LBUFFER" \
            --no-sort \
            --exact )

    if [[ -n "$selected" ]]; then
        LBUFFER=$selected
    fi
    zle reset-prompt
}

# Replace the basic fzf history binding
zle -N __fzf_history_advanced__
bindkey '^R' __fzf_history_advanced__

# === Tmux Integration ===
# Auto-sync history when creating new pane/window
if [[ -n "$TMUX" ]]; then
    # Sync on precmd (before each prompt)
    precmd_history_sync() {
        fc -RI  # Read and import new entries
    }

    # Add to precmd functions array
    precmd_functions+=(precmd_history_sync)
fi

# === Safety Features ===

# Prevent catastrophic history loss
history_protect() {
    # If history file is suspiciously small, restore from backup
    if [[ -f "$HISTFILE" ]] && [[ $(wc -l < "$HISTFILE") -lt 100 ]]; then
        echo "WARNING: History file seems corrupted (< 100 lines)"
        local latest_backup=$(ls -t ~/.zsh_history_backups/zsh_history_*.bak 2>/dev/null | head -1)
        if [[ -f "$latest_backup" ]]; then
            echo "Restoring from backup: $latest_backup"
            cp "$latest_backup" "$HISTFILE"
            fc -R
        fi
    fi
}

# Check on shell start
history_protect

# === Aliases for History Management ===
alias h='history'
alias hs='history_sync'
alias hd='history_dedupe'
alias hstats='history_stats'
alias hbackup='history_backup'
alias hgrep='fc -l 0 | grep'

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
