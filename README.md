# Tokyo Night Dotfiles

A personal collection of dotfiles with the Tokyo Night theme, managed with [GNU Stow](https://www.gnu.org/software/stow/) and controlled via a Makefile.

## Overview

This repository contains my personal configuration files (dotfiles) for various tools and applications I use daily, all themed with the beautiful Tokyo Night color scheme. The setup uses:

- **GNU Stow**: For symlink management
- **Makefile**: For easy command execution
- **Homebrew**: For package management on macOS
- **Homebrew Bundle**: For declarative Homebrew dependencies
- **mas**: For Mac App Store app management
- **Tokyo Night Theme**: A dark blue theme with vibrant colors applied to all tools

## Prerequisites

- macOS (some parts are macOS specific)
- Git
- Basic familiarity with the terminal

## Installation

### Quick Start

```bash
# Clone the repository to your home directory
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Navigate to the dotfiles directory
cd ~/dotfiles

# Install everything (Homebrew, packages, symlinks, macOS defaults)
make
```

### Step-by-Step Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install Homebrew and packages**:
   ```bash
   make brew
   make brew-bundle
   ```

3. **Set up symlinks using Stow**:
   ```bash
   # Install all configurations
   make stow-all
   
   # Or install specific configurations
   make stow-zsh
   make stow-vim
   make stow-git
   ```

4. **Apply macOS defaults**:
   ```bash
   make osx-defaults
   ```

5. **Install Mac App Store apps**:
   ```bash
   make mas-install
   ```

## Directory Structure

```
dotfiles/
├── .gitignore
├── Makefile
├── Brewfile
├── README.md
├── bin/
│   └── ... (scripts)
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── zsh/
│   ├── .zshrc
│   └── .zsh_aliases
├── vim/
│   └── .vimrc
├── tmux/
│   └── .tmux.conf
├── dircolors/
│   └── .dircolors
├── btop/
│   ├── .config/btop/btop.conf
│   └── .config/btop/themes/tokyonight.theme
├── htop/
│   └── .config/htop/htoprc
├── lazygit/
│   └── .config/lazygit/config.yml
├── colorterm/
│   └── .config/colorterm.conf
├── iterm2/
│   └── TokyoNight.itermcolors
└── ... (other application configs)
```

Each directory contains configuration files for a specific application. GNU Stow creates symlinks from your home directory to these files.

## Makefile Commands

| Command        | Description                                      |
|----------------|--------------------------------------------------|
| `make`         | Install everything (default target)              |
| `make install` | Same as `make`                                   |
| `make clean`   | Remove all symlinks                              |
| `make brew`    | Install or update Homebrew                       |
| `make brew-bundle` | Install packages from Brewfile                  |
| `make brew-dump`  | Export installed packages to Brewfile            |
| `make stow-all`  | Stow all configurations                          |
| `make stow-git`  | Stow git configuration                           |
| `make stow-vim`  | Stow vim configuration                           |
| `make stow-zsh`  | Stow zsh configuration                           |
| `make stow-tmux`  | Stow tmux configuration                          |
| `make stow-dircolors`  | Stow dircolors configuration                     |
| `make stow-btop`  | Stow btop configuration                          |
| `make stow-htop`  | Stow htop configuration                          |
| `make stow-lazygit`  | Stow lazygit configuration                       |
| `make stow-colorterm`  | Stow terminal color configuration                |
| `make stow-iterm2`  | Stow iTerm2 color scheme                         |
| `make osx-defaults` | Apply macOS default settings                     |
| `make mas-install` | Install Mac App Store applications               |

## Customization

### Adding New Configurations

1. Create a new directory for your application:
   ```bash
   mkdir mynewapp
   ```

2. Add configuration files to the directory, matching the structure they would have in your home directory:
   ```bash
   # For a file that would normally be at ~/.mynewapp/config
   mkdir -p mynewapp/.mynewapp
   touch mynewapp/.mynewapp/config
   ```

3. Add a new stow target to the Makefile:
   ```makefile
   stow-mynewapp:
       @echo "Stowing mynewapp configuration..."
       @stow -R mynewapp
   ```

4. Update the `stow-all` target in the Makefile:
   ```makefile
   stow-all: stow-git stow-vim stow-zsh stow-mynewapp
   ```

### Customizing Brew Packages

Edit the `Brewfile` to add or remove packages:

```ruby
# Add a new brew package
brew "package-name"

# Add a new cask application
cask "application-name"

# Add a Mac App Store application
mas "Application Name", id: 123456789
```

To find the ID of a Mac App Store application:
```bash
mas list
```

### Customizing macOS Defaults

Edit the `osx-defaults` target in the Makefile to add or modify macOS settings:

```makefile
osx-defaults:
    @echo "Applying macOS defaults..."
    @defaults write com.apple.finder NewSetting -bool true
    # Add more settings as needed
```

## Maintenance

### Updating Packages

```bash
# Update Homebrew and all packages
make brew

# Update the Brewfile with currently installed packages
make brew-dump
```

### Removing Symlinks

```bash
# Remove all symlinks
make clean

# Or manually remove specific symlinks
stow -D git
```

## Troubleshooting

### Stow Conflicts

If you get conflicts when stowing configurations:

1. Back up any existing configuration files
2. Remove the conflicting files
3. Try stowing again

### Homebrew Issues

If you encounter issues with Homebrew:

```bash
# Check Homebrew status
brew doctor

# Update Homebrew
brew update
```

## Tokyo Night Theme

This dotfiles collection uses the Tokyo Night theme across all applications:

### Color Palette

- **Background**: `#1a1b26` - Deep blue-black
- **Foreground**: `#c0caf5` - Light lavender
- **Selection**: `#283457` - Mid blue
- **Comment**: `#565f89` - Muted blue
- **Red**: `#f7768e` - Vibrant pink
- **Orange**: `#ff9e64` - Soft orange
- **Yellow**: `#e0af68` - Amber
- **Green**: `#9ece6a` - Lime green
- **Cyan**: `#7dcfff` - Sky blue
- **Blue**: `#7aa2f7` - Bright blue
- **Purple**: `#bb9af7` - Soft violet
- **Magenta**: `#bb9af7` - Lavender

### Themed Applications

All the following applications have been configured with the Tokyo Night theme:

- Vim/Neovim
- tmux
- Terminal colors (via dircolors)
- btop
- htop
- lazygit
- iTerm2

### Installation Notes

- For Vim/Neovim, Tokyo Night theme is installed through vim-plug
- For iTerm2, import the provided color scheme from Preferences > Profiles > Colors > Color Presets > Import
- All other applications have their theme files automatically symlinked with stow

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Homebrew](https://brew.sh/)
- [mas-cli](https://github.com/mas-cli/mas)
- [Tokyo Night Theme](https://github.com/enkia/tokyo-night-vscode-theme) - Original inspiration
