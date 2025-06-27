# Tokyo Night Color Scheme for Zsh
# Based on the Tokyo Night theme by enkia

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