cd() {
    builtin cd $@
    ls
}

function jcurl() {
    curl -s "$1" | jq
}

function mcom() {
    echo -n -e "\033]0;minicom\007"
    minicom -D $(ls -1 /dev/tty.usbserial-*) | ct
}

function cssh() {
    # Extract the hostname from SSH arguments
    local ssh_host=""
    local args=("$@")
    local skip_next=false

    for arg in "${args[@]}"; do
        if [[ "$skip_next" == true ]]; then
            skip_next=false
            continue
        fi

        # Skip SSH options that take arguments
        if [[ "$arg" =~ ^-(i|F|o|p|l|b|c|D|L|R|W)$ ]]; then
            skip_next=true
            continue
        fi

        # Skip other single-letter options
        if [[ "$arg" =~ ^-[a-zA-Z]$ ]]; then
            continue
        fi

        # Skip combined options like -vvv
        if [[ "$arg" =~ ^-[a-zA-Z]+$ ]]; then
            continue
        fi

        # Found the hostname/destination
        if [[ ! "$arg" =~ ^- ]]; then
            # Extract just the hostname part (remove user@ if present)
            ssh_host="${arg##*@}"
            # Remove port if specified with :port
            ssh_host="${ssh_host%%:*}"
            break
        fi
    done

    # Default to showing all args if we couldn't extract hostname
    local display_name="${ssh_host:-$@}"

    # Set terminal title (for non-tmux or as fallback)
    echo -n -e "\033]0;${display_name}\007"

    if [[ -n "$TMUX" ]] && [[ -n "$ssh_host" ]]; then
        # Save current automatic-rename setting
        local auto_rename=$(tmux show-window-option -v automatic-rename 2>/dev/null)
        # Temporarily rename window to SSH destination
        tmux rename-window "${ssh_host}" 2>/dev/null
        # Run SSH with ct pipe, using xterm for better compatibility with network devices
        TERM=xterm /usr/bin/ssh "$@" | ct
        local ssh_exit=$?
        # Restore automatic-rename
        tmux set-window-option automatic-rename "${auto_rename:-on}" 2>/dev/null
        return $ssh_exit
    else
        # If not in tmux or couldn't extract hostname, just run SSH with ct
        TERM=xterm /usr/bin/ssh "$@" | ct
    fi
}

function rs232() {
    echo -n -e "\033]0;rs232 port ${1}\007"
    ssh username+port${1}@2001:x:x:x:x::b | ct
}

# Network troubleshooting function
function netcheck() {
    local host=${1:-google.com}
    echo "=== Network Connectivity Check for $host ==="
    echo "Ping test:"
    ping -c 3 $host
    echo -e "\nTraceroute:"
    traceroute $host
    echo -e "\nDNS lookup:"
    nslookup $host
}

# Go project setup
function gonew() {
    local name=$1
    if [[ -z $name ]]; then
        echo "Usage: gonew <project-name>"
        return 1
    fi
    mkdir $name && cd $name
    go mod init $name
    echo "package main\n\nimport \"fmt\"\n\nfunc main() {\n    fmt.Println(\"Hello, $name!\")\n}" >main.go
    echo "Created Go project: $name"
}

# Pretty git status with Tokyo Night colors
function gst() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Not a git repository"
        return 1
    fi
    
    # Colors matching your prompt theme
    local blue="\033[38;2;122;162;247m"
    local cyan="\033[38;2;125;207;255m" 
    local green="\033[38;2;158;206;106m"
    local red="\033[38;2;247;118;142m"
    local orange="\033[38;2;255;158;100m"
    local fg="\033[38;2;192;202;245m"
    local comment="\033[38;2;86;95;137m"
    local reset="\033[0m"
    local bold="\033[1m"
    
    # Colors matching your prompt (%F{128} = branch, %F{162} = folder)
    local branch_color="\033[38;5;128m"    # Same as your prompt branch color
    local folder_color="\033[38;5;162m"    # Same as your prompt folder color
    
    echo "${branch_color}${bold}Repository Status${reset}"
    echo "${comment}────────────────────${reset}"
    
    # Branch info
    local branch=$(git branch --show-current 2>/dev/null)
    local upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    
    if [[ -n $branch ]]; then
        echo "${blue}Branch: ${branch_color}${bold}$branch${reset}"
        if [[ -n $upstream ]]; then
            local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
            echo "${blue}Upstream: ${green}$upstream${reset}"
            if [[ $ahead -gt 0 ]]; then
                echo "${folder_color}  ↑ $ahead commit(s) ahead${reset}"
            fi
            if [[ $behind -gt 0 ]]; then
                echo "${orange}  ↓ $behind commit(s) behind${reset}"
            fi
        fi
    fi
    
    echo ""
    
    # File status with custom formatting
    git status --porcelain | while IFS= read -r line; do
        local file_status="${line:0:2}"
        local file="${line:3}"
        
        case "$file_status" in
            "M ") echo "${folder_color}  Modified:   ${fg}$file${reset}" ;;
            " M") echo "${folder_color}  Modified:   ${fg}$file${reset}" ;;
            "MM") echo "${folder_color}  Modified:   ${fg}$file ${comment}(staged + unstaged)${reset}" ;;
            "A ") echo "${green}  Added:      ${fg}$file${reset}" ;;
            "D ") echo "${red}  Deleted:    ${fg}$file${reset}" ;;
            " D") echo "${red}  Deleted:    ${fg}$file${reset}" ;;
            "R ") echo "${branch_color}  Renamed:    ${fg}$file${reset}" ;;
            "C ") echo "${cyan}  Copied:     ${fg}$file${reset}" ;;
            "??") echo "${cyan}  Untracked:  ${fg}$file${reset}" ;;
            "!!") echo "${comment}  Ignored:    ${fg}$file${reset}" ;;
            "U ") echo "${red}  Conflict:   ${fg}$file${reset}" ;;
            " U") echo "${red}  Conflict:   ${fg}$file${reset}" ;;
            "UU") echo "${red}  Conflict:   ${fg}$file${reset}" ;;
        esac
    done
    
    # Summary
    local staged=$(git diff --cached --name-only | wc -l | tr -d ' ')
    local unstaged=$(git diff --name-only | wc -l | tr -d ' ')
    local untracked=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
    
    if [[ $staged -gt 0 ]] || [[ $unstaged -gt 0 ]] || [[ $untracked -gt 0 ]]; then
        echo ""
        echo "${comment}Summary: ${green}$staged staged${reset}, ${folder_color}$unstaged unstaged${reset}, ${cyan}$untracked untracked${reset}"
    else
        echo ""
        echo "${green}Working tree clean${reset}"
    fi
}
