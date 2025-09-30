# Carapace completion setup
# Only loads if carapace is installed

# Check if carapace is installed
if ! command -v carapace &> /dev/null; then
    return 0
fi

# Set up LS_COLORS with vivid if available
if command -v vivid &> /dev/null; then
    export LS_COLORS="$(vivid generate tokyonight-night)"
fi

# Bridge completions from other shells
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

# Format for completion descriptions
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

# Customize group order for specific commands
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# Initialize carapace
source <(carapace _carapace)
