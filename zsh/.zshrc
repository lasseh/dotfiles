# Path to your dotfiles directory
export DOTFILES="$HOME/dotfiles"

# Path to your oh-my-zsh installation (if used)
# export ZSH="$HOME/.oh-my-zsh"

# Set default editor
export EDITOR="vim"
export VISUAL="vim"

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# Basic auto/tab completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Load aliases
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# Add bin to path
[[ -d "$DOTFILES/bin" ]] && export PATH="$DOTFILES/bin:$PATH"

# Load dircolors (Tokyo Night theme)
if [ -x "$(command -v dircolors)" ]; then
  [[ -f ~/.dircolors ]] && eval "$(dircolors ~/.dircolors)"
fi

# Terminal color settings
if [[ -f ~/.config/colorterm.conf ]]; then
  source ~/.config/colorterm.conf
fi

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Node Version Manager (if installed)
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Load fzf (if installed via Homebrew)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Prompt setup (basic)
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '{%b}'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%n@%m%f:%F{green}%~%f %F{yellow}${vcs_info_msg_0_}%f $ '

# Add any other custom settings below

