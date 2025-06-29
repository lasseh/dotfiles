# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
export SYSTEMD_PAGER=

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h --max-depth=1'

# ==> Default overrides
alias .='pwd'
alias ..='cd ..'
alias tmuxad='tmux attach -d -t 0'

# Set default editor
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"

# ==> Grep colors
GREP_OPTIONS='--color=auto'
alias grep="grep $GREP_OPTIONS"
export GREP_COLORS="38;5;230:sl=38;5;240:cs=38;5;100:mt=38;5;161:fn=38;5;197:ln=38;5;212:bn=38;5;44:se=38;5;166"

# List directory contents using exa if available, otherwise ls
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --group-directories-first --git -mghas Name --long"
    alias lst="eza --group-directories-first --git --tree -mghs Name --long"
else
    alias ls="\ls -hovA --indicator-style=file-type --color=always --group-directories-first --time=ctime"
    alias lst="tree -C --du --si -L 5 --dirsfirst --prune"
fi

# Run  ls after changing directory
function cd() {
    builtin cd $@
    ls
}

# Lasse PS1 prompt
PS1='\[\e[0;38;5;32m\]\u\[\e[0;38;5;163m\]@\[\e[0;38;5;35m\]\H\[\e[0;38;5;163m\]:\[\e[m\] \[\e[0;38;5;32m\]\w\[\e[m\] \[\e[0;2m\]$(git branch 2>/dev/null | grep '"'"'^*'"'"' | colrm 1 2)\[\e[m\]\n\[\e[0;38;5;163m\]>\[\e[m\] \[\e0'

# Tokyo Night theme
#PS1='\[\e[0;38;5;117m\]\u\[\e[0;38;5;141m\]@\[\e[0;38;5;111m\]\H\[\e[0;38;5;141m\]:\[\e[m\] \[\e[0;38;5;149m\]\w\[\e[m\] \[\e[0;38;5;179m\]$(git branch 2>/dev/null | grep '"'"'^*'"'"' | colrm 1 2)\[\e[m\]\n\[\e[0;38;5;210m\]>\[\e[m\] '

# Load custom SSH completion
if [ -f ~/.bash_completion ]; then
    source ~/.bash_completion
fi

# Run motd script if it exists
if [ -x .dotfiles/bin/motd.sh ]; then
    .dotfiles/bin/motd.sh
fi
