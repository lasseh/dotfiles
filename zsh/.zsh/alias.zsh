# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/Projects"
alias g="git"
alias h="history"
alias j="jobs"

# List directory contents
alias ls="exa --group-directories-first --git"
alias ll="ls -l"
alias la="ls -la"
alias lt="ls --tree"

# Better defaults
alias cp="cp -i"       # Confirm before overwriting
alias mv="mv -i"       # Confirm before overwriting
alias rm="rm -i"       # Confirm before removing
alias mkdir="mkdir -p" # Create parent directories as needed
alias grep="grep --color=auto"
alias df="df -h"               # Human-readable sizes
alias du="du -h --max-depth=1" # Human-readable sizes

# ==> Default overrides
alias .='pwd'
alias ..='cd ..'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias sco='rm -O'
#alias nc='nc -v -w 3'
alias sloc="find . -name '*.go' | xargs wc -l"

# ==> Folder shortcuts
alias c='cd $HOME/code/go/src/github.com/lasseh'
alias svv='cd $HOME/code/go/src/github.com/lasseh/svv'

# ==> Tmux shortcuts
# to create dev/tech session: tmux new-session -s dev
alias tmuxa='tmux attach -t 0'
alias tmuxad='tmux attach -d -t 0'
alias tmuxdev='tmux attach -d -t dev'
alias tmuxnet='tmux attach -d -t net'
alias tmuxtech='tmux attach -d -t tech'

# ncurses fix
alias irssi='TERM=screen-256color irssi'
alias htop='TERM=screen-256color htop'
alias weechat='TERM=screen-256color weechat-curses'

# Git shortcuts
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias ga="git add"
alias gco="git checkout"
alias gb="git branch"
# ==> Git
alias ga='git add'
alias gpush='git push origin master'
alias gpull='git pull'
alias gd='git diff --color --no-ext-diff'
alias gdstat='git diff --color --stat'
alias gits='git status -sb'
alias gg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gits='git status -sb'
alias gcm='git commit --message'
alias gitbranches="git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'"
alias gcpush='git commit -a -m && git push origin'
alias gundo='git reset --soft HEAD~1'
alias gupdatesubm='git pull --recurse-submodules && git submodule update --recursive --remote'

# ==> Listing aliases
if which eza &>/dev/null; then
    alias ls="eza --group-directories-first --git -mghas Name --long"
    alias lst="eza --group-directories-first --git --tree -mghs Name --long --ignore-glob .git -a --depth=5"
    alias xa="eza"
    alias le="eza -lrhgHBimUa --git --group-directories-first"
else
    alias ls="\ls -hovA --indicator-style=file-type --color=always --group-directories-first --time=ctime"
    alias lst="tree -C --du --si -L 5 --dirsfirst --prune"
    alias ldot="\ls --indicator-style=file-type --color=always  -ld .*"
fi

# replace `cat` with `bat` if installed
if which bat &>/dev/null; then
    alias cat="bat"
    alias batdiff="bat --diff"
    alias batgrep="bat --grep"
    alias batless="bat --less='-R'"
fi
# replace `cat` with `batcat` if installed
if which batcat &>/dev/null; then
    alias cat="batcat"
    alias batdiff="batcat --diff"
    alias batgrep="batcat --grep"
    alias batless="batcat --less='-R'"
fi

# # ==> Utilities
alias randpasswd="LANG=c < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-64};echo;"

# VSCode
alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias icode="/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code"

# rs232
#alias rs232='function _myssh(){ ssh lassehau+port${1}@2001:x:x:x:b | ct };_myssh'

# Yolo
alias yolotail="ssh nms.as207788.net 'tail -n 0 -qf /var/log/network/c*.log | ccze -A'"

# Network config diff
alias nvimdiff="nvim -c ':DiffviewOpen @{1}..'"

# Sudo aliases to preserve user environment
alias svim='sudo -E vim'
