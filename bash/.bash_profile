# ~/.bash_profile
# Executed for login shells

# Set umask for better default permissions
umask 022

# Source the .bashrc file
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Path to your dotfiles directory
export DOTFILES="$HOME/.dotfiles"

# History configuration
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend

# Better bash completion
if [ -f /opt/homebrew/etc/bash_completion ]; then
    source /opt/homebrew/etc/bash_completion
fi

# Load dircolors (Tokyo Night theme)
if [ -x "$(command -v dircolors)" ]; then
    [ -f ~/.dircolors ] && eval "$(dircolors ~/.dircolors)"
fi

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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

# Add bin to path
[ -d "$DOTFILES/bin" ] && export PATH="$DOTFILES/bin:$PATH"

# Go configuration
export GOPATH="$HOME/code/go"
export PATH="$GOPATH/bin:$PATH"

# ==> FZF (Fuzzy Finder)
# Uncomment the following line if you want to use `fzf` for command line completion:
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Git prompt support
if [ -f /opt/homebrew/etc/bash_completion.d/git-prompt.sh ]; then
    source /opt/homebrew/etc/bash_completion.d/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWSTASHSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1
    export GIT_PS1_SHOWUPSTREAM="auto"
fi

# Better defaults
shopt -s checkwinsize # Check window size after each command
shopt -s cdspell      # Correct minor spelling errorsin cd
shopt -s dirspell     # Correct minor spelling errorsin directory names
shopt -s autocd       # Change to directory by typingits name


