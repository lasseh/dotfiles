# Path to your dotfiles directory
export DOTFILES="$HOME/dotfiles"

# Path to your zsh configuration.
export ZSH=$HOME/.zsh

# Set umask for better default permissions
umask 022

# Set default editor
export EDITOR="vim"
export VISUAL="vim"

# Basic auto/tab completion
autoload -Uz compinit  # Load the completion system function
compinit               # Initialize completions
zstyle ':completion:*' menu select           # Enable arrow-key navigation in completion menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion

# Pretty warnings
function _zwarn() { echo -ne "\e[38;5;196mWARNING \e[38;5;208m~>\e[0m $1\n"; }

#  Load custom zsh configuration files
source "${HOME}/.zsh/history.zsh" || _zwarn "Could not source ~/.zsh/history-config.zsh"
source "${HOME}/.zsh/alias.zsh" || _zwarn "Could not source ~/.zsh/alias.zsh"
source "${HOME}/.zsh/functions.zsh" || _zwarn "Could not source ~/.zsh/functions.zsh"
source "${HOME}/.zsh/fzf.zsh" || _zwarn "Could not source ~/.zsh/fzf.zsh"
source "${HOME}/.zsh/ssh-portforward.zsh" || _zwarn "Could not source ~/.zsh/ssh-portforward.zsh"
source "${HOME}/.zsh/ssh-fzf.zsh" || _zwarn "Could not source ~/.zsh/ssh-fzf-fixed.zsh"
source "${HOME}/.zsh/tokyo-night-theme.zsh" || _zwarn "Could not source ~/.zsh/tokyo-night-theme.zsh"

# TODO: Check if carapace is installed, otherwise skip
# TODO: Add vivid theme for carapace
# TODO: replace vivid with LS_COLORS config
#source "${HOME}/.zsh/carapace.zsh" || _zwarn "Could not source ~/.zsh/carapace.zsh"

# Load dircolors
if [ -x "$(command -v dircolors)" ]; then
    [[ -f ~/.dircolors ]] && eval "$(dircolors ~/.dircolors)"
fi

# Set eza config folder
export EZA_CONFIG_DIR="$HOME/.config/eza"

# Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Go configuration
export GOPATH="$HOME/code/go"
export GOPROXY="https://proxy.golang.org,direct"

# Detect GOROOT based on platform/installation method
if command -v go >/dev/null 2>&1; then
    # Go already in PATH (e.g., via Homebrew), get GOROOT from go command
    export GOROOT="$(go env GOROOT)"
elif [[ -d "/usr/local/go" ]]; then
    # Linux standard manual installation
    export GOROOT="/usr/local/go"
    export PATH="$GOROOT/bin:$PATH"
elif [[ -d "/opt/homebrew/opt/go/libexec" ]]; then
    # macOS Apple Silicon Homebrew
    export GOROOT="/opt/homebrew/opt/go/libexec"
    export PATH="$GOROOT/bin:$PATH"
elif [[ -d "/usr/local/opt/go/libexec" ]]; then
    # macOS Intel Homebrew
    export GOROOT="/usr/local/opt/go/libexec"
    export PATH="$GOROOT/bin:$PATH"
fi

# Add Go workspace bin to PATH
export PATH="$GOPATH/bin:$PATH"

# Extra paths
[[ -d "$DOTFILES/bin" ]] && export PATH="$DOTFILES/bin:$PATH" # For custom scripts
export PATH="$HOME/.local/bin:$PATH" # For user-specific binaries
export PATH="$HOME/.opencode/bin:$PATH" # For opencode CLI tool
export PATH="/opt/homebrew/opt/libpq/bin:$PATH" # For libpq tools like psql

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/lasse/.bun/_bun" ] && source "/Users/lasse/.bun/_bun"

