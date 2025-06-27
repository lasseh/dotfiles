# Pretty SSH Autocompletion using fzf
# This script provides a way to use fzf for SSH host completion in Zsh.
my_fzf_ssh() {
    local host query
    if [[ $LBUFFER == "ssh "* ]]; then
        query="${LBUFFER#ssh }"
    else
        query=""
    fi
    host=$(grep -E "^Host " ~/.ssh/{work.d,private.d}/*.conf |
        awk '{print $2}' |
        fzf --height=40% --extended --layout=reverse --border --info=hidden \
            --prompt="SSH> " --query="$query" --select-1 --exact)
    if [[ -n "$host" ]]; then
        BUFFER="cssh $host"
        CURSOR=${#BUFFER} # Move cursor to the end
        zle reset-prompt
    fi
}

zle -N my_fzf_ssh
# bindkey '^S' my_fzf_ssh
# stty -ixon # Ensure Ctrl-S isn't blocked by the terminal

_fzf_complete_ssh() {
    # If the current buffer looks like "ssh" or "ssh " (or is empty), call my_fzf_ssh.
    if [[ $LBUFFER == 'ssh '* || $LBUFFER == 'ssh' || -z $LBUFFER ]]; then
        my_fzf_ssh
    else
        # Otherwise, fall back to the default completion behavior.
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}

# Enable fzf completion for ssh
if [[ -n $ZSH_VERSION ]]; then
    autoload -U +X compinit && compinit
    fzf_default_completion='expand-or-complete'
    [[ -n $fzf_default_completion ]] && zle -N _fzf_complete_ssh
    bindkey '^I' _fzf_complete_ssh # Bind Tab only for SSH
fi
