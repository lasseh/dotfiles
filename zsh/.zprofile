# ====================================================================
# SSH Agent Management
# Automatically starts and manages ssh-agent across shell sessions
# This ensures SSH keys are loaded and available without manual intervention
# ====================================================================

# SSH Agent setup - only run if ssh-agent is available
if command -v ssh-agent >/dev/null 2>&1; then
    # Check if SSH_AUTH_SOCK is already set (agent already running or forwarded)
    # Skip starting local agent if we're in an SSH session (forwarding might be active)
    if [[ -z "$SSH_AUTH_SOCK" && -z "$SSH_CONNECTION" ]]; then

        # Path to store ssh-agent environment variables
        agent_env="$HOME/.agent.env"

        if [[ -f "$agent_env" ]]; then
            # Load existing agent environment
            source "$agent_env" >/dev/null 2>&1

            # Check if the loaded agent is still running
            # kill -0 sends no signal but checks if process exists
            if ! kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1; then
                # Agent is dead, start a new one
                ssh-agent -s >"$agent_env"
                source "$agent_env" >/dev/null 2>&1
            fi
        else
            # No existing agent file, start fresh
            ssh-agent -s >"$agent_env"
            source "$agent_env" >/dev/null 2>&1
        fi
    fi
fi

# Homebrew Environment Setup
# This configures Homebrew's environment variables (PATH, MANPATH, etc.) for the current shell.
# It handles different architectures and installation locations automatically:
# - Apple Silicon Macs: /opt/homebrew
# - Intel Macs: /usr/local
# - Linux: /home/linuxbrew or ~/.linuxbrew
# This ensures brew commands work regardless of how/where Homebrew was installed.

if command -v brew >/dev/null 2>&1; then
    # brew is already in PATH, just run shellenv
    eval "$(brew shellenv)"
elif [[ -x "/opt/homebrew/bin/brew" ]]; then
    # Apple Silicon Mac (M1/M2) - standard location
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    # Intel Mac - standard location
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    # Linux - standard Linuxbrew location
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    # Linux - user Linuxbrew location
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
else
    # Fallback: try to find brew in common locations
    for brew_path in \
        "/opt/homebrew/bin/brew" \
        "/usr/local/bin/brew" \
        "/home/linuxbrew/.linuxbrew/bin/brew" \
        "$HOME/.linuxbrew/bin/brew" \
        "$HOME/homebrew/bin/brew"; do
        if [[ -x "$brew_path" ]]; then
            eval "$($brew_path shellenv)"
            break
        fi
    done
fi
