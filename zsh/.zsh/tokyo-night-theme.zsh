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
    # Check if in SSH session
    local prefix=""
    [[ -n "$SSH_CLIENT" ]] && prefix="[SSH] "
    
    # Get git repo name if in a git repository
    local repo_name=$(git rev-parse --show-toplevel 2>/dev/null)
    repo_name=${repo_name##*/}
    
    # Build the title
    if [[ -n "$repo_name" ]]; then
        # In git repo: show repo name with path relative to repo root
        local rel_path=$(git rev-parse --show-prefix 2>/dev/null)
        rel_path=${rel_path%/}  # Remove trailing slash
        if [[ -n "$rel_path" ]]; then
            print -Pn "\e]0;${prefix}${USER}@%m: ${repo_name}/${rel_path}\a"
        else
            print -Pn "\e]0;${prefix}${USER}@%m: ${repo_name}\a"
        fi
    else
        # Not in git repo: show shortened path with ~
        print -Pn "\e]0;${prefix}${USER}@%m: %~\a"
    fi
}

# Precmd function for info line with Tokyo Night colors
precmd() {
    vcs_info
    update_title
    print -P "\\n%F{32}%n%F{163}@%F{35}%M%F{163}:%f $(repo_information)"
}

# Final prompt definition with Tokyo Night colors
PROMPT="%(?.%F{32}.%F{196})❯%f "
