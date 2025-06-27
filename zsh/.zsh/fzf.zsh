# fzf configuration
if which fzf &>/dev/null; then
    # Set default command to use ag if available, otherwise find
    if which ag &>/dev/null; then
        export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
    else
        export FZF_DEFAULT_COMMAND='find . -type f'
    fi
    
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="find . -type d"
    
    # Enhanced color scheme
    export FZF_DEFAULT_OPTS="
        --height 40% 
        --layout=reverse 
        --border 
        --inline-info
        --color=bg+:#283457
        --color=bg:#16161e
        --color=border:#27a1b9
        --color=fg:#c0caf5
        --color=gutter:#16161e
        --color=header:#ff9e64
        --color=hl+:#2ac3de
        --color=hl:#2ac3de
        --color=info:#545c7e
        --color=marker:#ff007c
        --color=pointer:#ff007c
        --color=prompt:#2ac3de
        --color=query:#c0caf5:regular
        --color=scrollbar:#27a1b9
        --color=separator:#ff9e64
        --color=spinner:#ff007c
    "
    
    # Manual key bindings for ctrl-r (history search)
    __fzf_history__() {
        local output
        output=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | 
                fzf --query="$LBUFFER" --no-sort --tac --exact) &&
        LBUFFER=$output
        zle reset-prompt
    }
    zle -N __fzf_history__
    bindkey '^R' __fzf_history__
    
    # ctrl-t for file search
    __fzf_file__() {
        local output
        output=$(eval "$FZF_DEFAULT_COMMAND" | fzf --query="$LBUFFER") &&
        LBUFFER="${LBUFFER}$output"
        zle reset-prompt
    }
    zle -N __fzf_file__
    bindkey '^T' __fzf_file__
fi
