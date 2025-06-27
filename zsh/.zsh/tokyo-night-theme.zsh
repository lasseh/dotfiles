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
zstyle ':vcs_info:*:*' formats "%F{162}%r%f/%F{128}%b%f" "%u%c"
zstyle ':vcs_info:*:*' actionformats "%F{162}%r%f/%F{128}%b%f" "%u%c (%a)"
zstyle ':vcs_info:*:*' nvcsformats "%~" ""

# Check if repo is dirty
git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    command git diff --quiet --ignore-submodules HEAD &>/dev/null
    [ $? -eq 1 ] && echo "*"
}

# Repository information display with Tokyo Night colors
repo_information() {
    echo "%F{162}${vcs_info_msg_0_%%/.}%f %F{128}${vcs_info_msg_1_}$(git_dirty)%f"
}

# Command execution time
cmd_exec_time() {
    local stop=$(date +%s)
    local start=${cmd_timestamp:-$stop}
    let local elapsed=$stop-$start
    [ $elapsed -gt 5 ] && echo "${elapsed}s"
}

# Get timestamp for exec time
preexec() {
    cmd_timestamp=$(date +%s)
}

# Precmd function for info line with Tokyo Night colors
precmd() {
    vcs_info
    print -P "\\n%F{32}%n%F{163}@%F{35}%m%F{163}:%f $(repo_information) %F{162}$(cmd_exec_time)%f"
}

# Final prompt definition with Tokyo Night colors
PROMPT="%(?.%F{32}.%F{196})❯%f "
