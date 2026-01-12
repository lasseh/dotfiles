# Intelligent SSH Host Completion with fzf
# This provides smart SSH host completion that integrates cleanly with zsh

# Function to extract SSH hosts from config files
_get_ssh_hosts() {
    local hosts=()
    local config_files

    # Find all SSH config files (main config and any includes)
    config_files=(~/.ssh/config)

    # Check for additional config directories if they exist
    [[ -d ~/.ssh/config.d ]] && config_files+=(~/.ssh/config.d/*.conf)
    [[ -d ~/.ssh/work.d ]] && config_files+=(~/.ssh/work.d/*.conf)
    [[ -d ~/.ssh/private.d ]] && config_files+=(~/.ssh/private.d/*.conf)

    # Extract hosts from all config files that exist
    for file in $config_files; do
        if [[ -f "$file" ]]; then
            # Extract Host entries (excluding wildcards and patterns)
            grep -E "^Host\s+" "$file" 2>/dev/null | \
                awk '{for(i=2;i<=NF;i++) print $i}' | \
                grep -v '[*?!]'
        fi
    done | sort -u
}

# FZF-based SSH completion
_fzf_ssh_complete() {
    local selected
    local hosts
    local query=""
    local prefix=""

    # Extract the partial hostname already typed (if any)
    if [[ "$LBUFFER" =~ (ssh|cssh|scp|sftp|rsync.*ssh)[[:space:]]+([^[:space:]]*)$ ]]; then
        query="${match[2]}"
        # Store everything except the partial hostname
        prefix="${LBUFFER%$query}"
    else
        prefix="$LBUFFER"
    fi

    # Get available hosts
    hosts=$(_get_ssh_hosts)

    if [[ -z "$hosts" ]]; then
        # No hosts found, fall back to default completion
        return 1
    fi

    # Use fzf to select a host, with the partial hostname as initial query
    selected=$(echo "$hosts" | fzf \
        --height=40% \
        --layout=reverse \
        --border \
        --prompt="SSH Host> " \
        --query="$query" \
        --select-1 \
        --exit-0)

    if [[ -n "$selected" ]]; then
        # Replace the buffer with prefix + selected host
        LBUFFER="${prefix}${selected}"
    fi

    zle reset-prompt
    return 0
}

# Smart SSH completion widget
ssh_smart_complete() {
    # Extract the current word being typed
    local current_word=""
    if [[ "$LBUFFER" =~ [^[:space:]]+$ ]]; then
        current_word="${MATCH}"
    fi

    # For ssh/cssh, use fzf host completion (these always need a host)
    if [[ "$LBUFFER" =~ ^(ssh|cssh)[[:space:]]+ ]]; then
        # Skip if typing an option (starts with -)
        if [[ "$current_word" =~ ^- ]]; then
            zle expand-or-complete
            return
        fi
        if ! _fzf_ssh_complete; then
            zle expand-or-complete
        fi
        return
    fi

    # For scp/sftp/rsync, use normal zsh completion (handles both files and hosts)
    zle expand-or-complete
}

# Register the widget
zle -N ssh_smart_complete

# Override Tab only when typing SSH commands
# This uses a more intelligent binding that checks context
bindkey '^I' ssh_smart_complete

# Optional: Add a dedicated hotkey for SSH host selection
# This can be used anywhere in the command line
ssh_host_picker() {
    local host
    host=$(_get_ssh_hosts | fzf \
        --height=40% \
        --layout=reverse \
        --border \
        --prompt="Pick SSH Host> ")

    if [[ -n "$host" ]]; then
        LBUFFER="${LBUFFER}${host}"
        zle reset-prompt
    fi
}

zle -N ssh_host_picker
# Uncomment to enable Ctrl+S for SSH host picker
# bindkey '^S' ssh_host_picker

# Standard zsh SSH completion as fallback
# This ensures we still have basic completion if fzf isn't available
if (( $+commands[ssh] )); then
    # Load SSH completion if not already loaded
    autoload -U +X compinit && compinit

    # Configure ssh completion to use known_hosts and config
    zstyle ':completion:*:ssh:*' hosts $(
        {
            [[ -r ~/.ssh/known_hosts ]] && \
                awk '{print $1}' ~/.ssh/known_hosts | \
                cut -d, -f1 | cut -d: -f1
            _get_ssh_hosts
        } 2>/dev/null | sort -u
    )
fi
