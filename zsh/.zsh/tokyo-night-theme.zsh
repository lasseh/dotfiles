# Tokyo Night Theme for Zsh

# Tokyo Night color definitions
export TOKYO_NIGHT_BG="#1a1b26"
export TOKYO_NIGHT_FG="#c0caf5"
export TOKYO_NIGHT_BLUE="#7aa2f7"
export TOKYO_NIGHT_CYAN="#7dcfff"
export TOKYO_NIGHT_GREEN="#9ece6a"
export TOKYO_NIGHT_MAGENTA="#bb9af7"
export TOKYO_NIGHT_RED="#f7768e"
export TOKYO_NIGHT_YELLOW="#e0af68"
export TOKYO_NIGHT_ORANGE="#ff9e64"
export TOKYO_NIGHT_PURPLE="#9d7cd8"
export TOKYO_NIGHT_TEAL="#1abc9c"
export TOKYO_NIGHT_COMMENT="#565f89"
export TOKYO_NIGHT_DARK_BLUE="#414868"

# Set LS_COLORS for Tokyo Night theme
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"

# Set terminal colors if supported
if [[ $TERM == *"256color"* ]] || [[ $TERM == "xterm-kitty" ]]; then
    # Set cursor color
    echo -ne "\e]12;#c0caf5\a"
fi

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
    # Get git repo name if in a git repository
    local repo_name=$(git rev-parse --show-toplevel 2>/dev/null)
    repo_name=${repo_name##*/}

    # Build the base title
    local base_title
    if [[ -n "$repo_name" ]]; then
        # In git repo: show repo name with path relative to repo root
        local rel_path=$(git rev-parse --show-prefix 2>/dev/null)
        rel_path=${rel_path%/}  # Remove trailing slash
        if [[ -n "$rel_path" ]]; then
            base_title="${USER}@%m: ${repo_name}/${rel_path}"
        else
            base_title="${USER}@%m: ${repo_name}"
        fi
    else
        # Not in git repo: show shortened path with ~
        base_title="${USER}@%m: %~"
    fi

    # If in tmux, intelligently append the window name
    local title_string="$base_title"
    if [[ -n "$TMUX" ]]; then
        local tmux_window=$(tmux display-message -p '#W' 2>/dev/null)
        local pane_command=$(tmux display-message -p '#{pane_current_command}' 2>/dev/null)

        # Only show window name if it's different from the pane command
        # This indicates a manually-set window name
        if [[ -n "$tmux_window" ]] && [[ "$tmux_window" != "$pane_command" ]]; then
            title_string="$base_title [$tmux_window]"
        elif [[ -n "$pane_command" ]]; then
            # Show the actual running command (more reliable than window name)
            title_string="$base_title [$pane_command]"
        fi
    fi

    # Set terminal title
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
    # Get the command being run
    local cmd=${1%% *}
    # Remove any leading path
    cmd=${cmd##*/}

    if [[ -n "$TMUX" ]]; then
        # In tmux, show the path context with the command
        # Get git repo name if in a git repository
        local repo_name=$(git rev-parse --show-toplevel 2>/dev/null)
        repo_name=${repo_name##*/}

        local context
        if [[ -n "$repo_name" ]]; then
            local rel_path=$(git rev-parse --show-prefix 2>/dev/null)
            rel_path=${rel_path%/}
            if [[ -n "$rel_path" ]]; then
                context="${repo_name}/${rel_path}"
            else
                context="${repo_name}"
            fi
        else
            context=$(print -Pn "%~")
        fi

        # Show context with command
        local title_string="${USER}@%m: ${context} [${cmd}]"
        print -Pn "\e]2;${title_string}\a"
    else
        # Outside tmux, show the running command
        local title_string="${USER}@%m: [${cmd}]"
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
