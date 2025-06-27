# Path to your dotfiles directory
export DOTFILES="$HOME/dotfiles-new"

# Path to your zsh configuration.
export ZSH=$HOME/.zsh

# Path to your oh-my-zsh installation (if used)
# export ZSH="$HOME/.oh-my-zsh"

# Set default editor
export EDITOR="vim"
export VISUAL="vim"

# History configuration
HISTFILE="$HOME/.zsh_history" # Path to history file
HISTSIZE=10000                #  Number of history entries to keep in memory
SAVEHIST=10000                # Number of history entries to save
setopt HIST_IGNORE_ALL_DUPS   # Ignore duplicate commands
setopt HIST_REDUCE_BLANKS     # Remove extra blanks
setopt HIST_VERIFY            # Verify history expansion
setopt INC_APPEND_HISTORY     # Append to history file immediately
setopt SHARE_HISTORY          # Share history across all sessions

# Basic auto/tab completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Disable all default SSH completion sources
zstyle ':completion:*:(ssh|scp|sftp):*' tag-order '! hosts'
zstyle ':completion:*:(ssh|scp|sftp):*:hosts' ignored-patterns '*'

# Load zsh plugins
# Pretty warnings
function _zwarn() { echo -ne "\e[38;5;196mWARNING \e[38;5;208m~>\e[0m $1\n"; }

#  Load custom zsh configuration files
source "${HOME}/.zsh/alias.zsh" || _zwarn "Could not source ~/.zsh/alias.zsh"
source "${HOME}/.zsh/functions.zsh" || _zwarn "Could not source ~/.zsh/functions.zsh"
source "${HOME}/.zsh/fzf.zsh" || _zwarn "Could not source ~/.zsh/fzf.zsh"
source "${HOME}/.zsh/tokyo-night-colors.zsh" || _zwarn "Could not source ~/.zsh/tokyo-night-colors.zsh"
source "${HOME}/.zsh/tokyo-night-theme.zsh" || _zwarn "Could not source ~/.zsh/tokyo-night-theme.zsh"

# Add bin to path
[[ -d "$DOTFILES/bin" ]] && export PATH="$DOTFILES/bin:$PATH"

# Load dircolors
if [ -x "$(command -v dircolors)" ]; then
    [[ -f ~/.dircolors ]] && eval "$(dircolors ~/.dircolors)"
fi

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# SSH tab completion optimization - only show configured hosts
_ssh_hosts_completion() {
    local -a ssh_hosts
    # Extract Host entries from SSH config files, excluding wildcards and comments
    ssh_hosts=($(awk '
        /^Host / { 
            for(i=2; i<=NF; i++) {
                if($i !~ /[*?]/ && $i !~ /^#/) {
                    print $i
                }
            }
        }
    ' ~/.ssh/config ~/.ssh/work.d/*.conf ~/.ssh/private.d/*.conf 2>/dev/null | sort -u))

    _describe 'ssh hosts' ssh_hosts
}

# Disable default SSH host completion sources
zstyle ':completion:*:ssh:*' hosts off
zstyle ':completion:*:scp:*' hosts off
zstyle ':completion:*:sftp:*' hosts off
zstyle ':completion:*:ssh:*' users-hosts off
zstyle ':completion:*:scp:*' users-hosts off
zstyle ':completion:*:sftp:*' users-hosts off

# Override default SSH completion to use only configured hosts
compdef _ssh_hosts_completion ssh
compdef _ssh_hosts_completion scp
compdef _ssh_hosts_completion sftp

# Force reload of completion system
autoload -U compinit && compinit -d

# Precmd function for info line
precmd() {
    vcs_info
    print -P "\n%F{blue}%n%F{red}@%F{green}%m%F{red}:%f $(repo_information) %F{yellow}$(cmd_exec_time)%f"
}

# Final prompt definition - refined theme style
PROMPT="%(?.%F{magenta}.%F{red})❯%f "
