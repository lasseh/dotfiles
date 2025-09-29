# Tokyo Night Theme for Zsh
# Based on your existing refined theme with Tokyo Night colors

# Load Tokyo Night colors
source "${HOME}/.zsh/tokyo-night-colors.zsh"

setopt prompt_subst
autoload -Uz vcs_info

# vcs_info configuration with Tokyo Night colors
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' formats "%r|%S|%b" "%u%c"
zstyle ':vcs_info:*:*' actionformats "%r|%S|%b" "%u%c (%a)"
zstyle ':vcs_info:*:*' nvcsformats "%~" ""

# Check if repo is dirty
git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    command git diff --quiet --ignore-submodules HEAD &>/dev/null
    [ $? -eq 1 ] && echo "*"
}

# Repository information display with Tokyo Night colors
repo_information() {
    # Check if we're in a git repo by looking for the pipe separator
    if [[ "${vcs_info_msg_0_}" != *"|"* ]]; then
        # Not in git repo, just show the path
        echo "%F{162}${vcs_info_msg_0_}%f"
        return
    fi
    
    local info=(${(s:|:)vcs_info_msg_0_})
    # Ensure we have at least 3 components
    if [[ ${#info[@]} -lt 3 ]]; then
        # Fallback to showing the raw message if parsing fails
        echo "%F{162}${vcs_info_msg_0_}%f"
        return
    fi
    
    local repo_name="$info[1]"
    local subpath="$info[2]"
    local branch="$info[3]"
    
    # Build path: repo + subpath (if not in root)
    local display_path="$repo_name"
    [[ "$subpath" != "." ]] && display_path="$repo_name/$subpath"
    
    echo "%F{162}${display_path}%f %F{163}❯%f %F{128}${branch}$(git_dirty)%f %F{128}${vcs_info_msg_1_}%f"
}



# Update terminal title with current directory
update_title() {
    # If in tmux AND connected via SSH, just use the tmux window name
    if [[ -n "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
        local tmux_window=$(tmux display-message -p '#W' 2>/dev/null)
        if [[ -n "$tmux_window" ]]; then
            # Use tmux window name in the title
            local title_string="${USER}@%m: ${tmux_window}"
            print -Pn "\e]2;${title_string}\a"
            return
        fi
    fi

    # Get git repo name if in a git repository
    local repo_name=$(git rev-parse --show-toplevel 2>/dev/null)
    repo_name=${repo_name##*/}

    # Build the title - works in both terminal and tmux
    local title_string
    if [[ -n "$repo_name" ]]; then
        # In git repo: show repo name with path relative to repo root
        local rel_path=$(git rev-parse --show-prefix 2>/dev/null)
        rel_path=${rel_path%/}  # Remove trailing slash
        if [[ -n "$rel_path" ]]; then
            title_string="${USER}@%m: ${repo_name}/${rel_path}"
        else
            title_string="${USER}@%m: ${repo_name}"
        fi
    else
        # Not in git repo: show shortened path with ~
        title_string="${USER}@%m: %~"
    fi

    # Set title using both standard escape sequence and tmux if available
    if [[ -n "$TMUX" ]]; then
        # Inside tmux - only set the terminal title, not the window name
        print -Pn "\e]2;${title_string}\a"
    else
        # Regular terminal
        print -Pn "\e]0;${title_string}\a"
    fi
}

# Update terminal title with running command
update_title_preexec() {
    # If in tmux AND connected via SSH, just use the tmux window name (tmux manages it)
    if [[ -n "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
        local tmux_window=$(tmux display-message -p '#W' 2>/dev/null)
        if [[ -n "$tmux_window" ]]; then
            local title_string="${USER}@%m: ${tmux_window}"
            print -Pn "\e]2;${title_string}\a"
            return
        fi
    fi

    # Show the running command
    local cmd=${1%% *}
    # Remove any leading path
    cmd=${cmd##*/}
    local title_string="${USER}@%m: [${cmd}]"

    # Set title using both standard escape sequence and tmux if available
    if [[ -n "$TMUX" ]]; then
        # Inside tmux - only set the terminal title, not the window name
        print -Pn "\e]2;${title_string}\a"
    else
        # Regular terminal
        print -Pn "\e]0;${title_string}\a"
    fi
}

# Precmd function for info line with Tokyo Night colors
precmd() {
    vcs_info
    update_title
    print -P "\\n%F{32}%n%F{163}@%F{35}%M%F{163}:%f $(repo_information)"
}

# Preexec function to update title with running command
preexec() {
    update_title_preexec "$1"
}

# Final prompt definition with Tokyo Night colors
PROMPT="%(?.%F{32}.%F{196})❯%f "
