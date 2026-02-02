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
alias sloc="find . -name '*.go' | xargs wc -l"

# ==> Folder shortcuts
alias c='cd $HOME/code/go/src/github.com/lasseh'
alias s='cd $HOME/code/go/src/github.com/lasseh/svv'

# ==> Tmux
alias tmuxa='tmux attach -t 0'
alias tmuxad='tmux attach -d -t 0'
alias tmuxx='tmux attach -d -t main 2>/dev/null || tmux new -s main'
alias tmuxs='tmux attach -d -t svv 2>/dev/null || tmux new -s svv'

# ncurses fix
alias irssi='TERM=screen-256color irssi'
alias htop='TERM=screen-256color htop'
alias weechat='TERM=screen-256color weechat-curses'


# Git shortcuts
alias gs="gst"  # Use our pretty status function
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias ga="git add"
alias gco="git checkout"
alias gb="git branch"
# ==> Git
alias ga='git add'
alias gpush='git push origin main'
alias gpull='git pull'
alias gd='git diff --color --no-ext-diff'
alias gdstat='git diff --color --stat'
alias gits='git status -sb'
alias gg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gcm='git commit --message'
alias gitbranches="git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'"
alias gcpush='git commit -a -m && git push origin'
alias gundo='git reset --soft HEAD~1'
alias gupdatesubm='git pull --recurse-submodules && git submodule update --recursive --remote'

# # ==> Utilities
alias randpasswd="LANG=c < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-64};echo;"

# VSCode
alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias icode="/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code"

# rs232
#alias rs232='function _myssh(){ ssh lassehau+port${1}@2001:x:x:x:b | ct };_myssh'

# Yolo
alias yolotail="ssh nms.as207788.net 'tail -n 0 -qf /var/log/network/c*.log | ccze -A'"

# ==> Enhanced log viewing with ccze
alias syslog="tail -f /var/log/system.log | ccze -A"
alias authlog="tail -f /var/log/auth.log | ccze -A"
alias maillog="tail -f /var/log/mail.log | ccze -A"
alias cczelog="ccze -A"  # Pipe any log through this

# Network config diff
alias nvimdiff="nvim -c ':DiffviewOpen @{1}..'"

# ==> Network Engineering aliases
alias localip="ipconfig getifaddr en0"
alias netinfo="ifconfig | grep -E 'inet'"

# ==> Go development aliases
alias gobuild="go build -v"
alias gorun="go run ."
alias goclean="go clean -cache -modcache -i -r"
alias gomod="go mod tidy && go mod verify"
alias golint="golangci-lint run"

# ==> Docker/Container aliases
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dlog="docker logs -f"
alias dexec="docker exec -it"
alias dclean="docker system prune -af"

# Sudo aliases to preserve user environment and colorscheme
alias svim='sudo -E vim'
alias scat='sudo -E batcat'
alias stail='sudo -E tail'
alias shtop='sudo -E htop'
alias sbtop='sudo -E btop'

# ==> Listing aliases
if which eza &>/dev/null; then
    alias ls="eza --group-directories-first --git -mghas Name --long"
    alias lst="eza --group-directories-first --git --tree -mghs Name --long --ignore-glob .git -a"
    alias xa="eza"
    alias le="eza -lrhgHBimUa --git --group-directories-first"
else
    alias ls="\\ls -hovAG"
    alias lst="tree -C --du --si -L 5 --dirsfirst --prune"
    alias ldot="\\ls -ldG .*"
fi

# replace `cat` with `bat` if installed (only in interactive shells)
# This prevents Claude Code and other scripts from getting bat's formatted output
if [[ $- == *i* ]]; then
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
fi
