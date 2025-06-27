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
zstyle ':vcs_info:*:*' formats "%F{#f7768e}%r%f/%F{#bb9af7}%b%f" "%u%c"
zstyle ':vcs_info:*:*' actionformats "%F{#f7768e}%r%f/%F{#bb9af7}%b%f" "%u%c (%a)"
zstyle ':vcs_info:*:*' nvcsformats "%~" ""

# Check if repo is dirty
git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    command git diff --quiet --ignore-submodules HEAD &>/dev/null
    [ $? -eq 1 ] && echo "*"
}

# Repository information display with Tokyo Night colors
repo_information() {
    echo "%F{#f7768e}${vcs_info_msg_0_%%/.}%f %F{#bb9af7}${vcs_info_msg_1_}$(git_dirty)%f"
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
    print -P "\n%F{#414868}%n%F{#c53b53}@%F{#73a373}%m%F{#f7768e}:%f $(repo_information) %F{#e0af68}$(cmd_exec_time)%f"
}

# Final prompt definition with Tokyo Night colors
PROMPT="%(?.%F{#bb9af7}.%F{#f7768e})❯%f "