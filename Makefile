.PHONY: all install clean brew brew-bundle brew-dump stow-all stow-git stow-vim stow-zsh stow-tmux stow-dircolors stow-btop stow-htop stow-lazygit stow-colorterm stow-iterm2 osx-defaults

# Default target
all: install

# Install everything
install: brew stow-all osx-defaults

# Clean up
clean:
	@echo "Removing symlinks..."
	@stow -D git vim zsh # Add more packages as needed
	@echo "Done!"

# Brew related targets
brew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "Homebrew already installed, updating..."; \
		brew update; \
		brew upgrade; \
	fi

brew-bundle:
	@echo "Installing packages from Brewfile..."
	@brew bundle --file=./Brewfile

brew-dump:
	@echo "Exporting installed packages to Brewfile..."
	@brew bundle dump --force

# Stow related targets
stow-all: stow-git stow-vim stow-zsh stow-tmux stow-dircolors stow-btop stow-htop stow-lazygit stow-colorterm stow-iterm2
	@echo "All configurations stowed!"

stow-git:
	@echo "Stowing git configuration..."
	@stow -R git

stow-vim:
	@echo "Stowing vim configuration..."
	@stow -R vim

stow-zsh:
	@echo "Stowing zsh configuration..."
	@stow -R zsh

stow-tmux:
	@echo "Stowing tmux configuration..."
	@stow -R tmux

stow-dircolors:
	@echo "Stowing dircolors configuration..."
	@stow -R dircolors

stow-btop:
	@echo "Stowing btop configuration..."
	@stow -R btop

stow-htop:
	@echo "Stowing htop configuration..."
	@stow -R htop

stow-lazygit:
	@echo "Stowing lazygit configuration..."
	@stow -R lazygit

stow-colorterm:
	@echo "Stowing terminal color configuration..."
	@stow -R colorterm

stow-iterm2:
	@echo "Stowing iTerm2 configuration..."
	@mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
	@cp iterm2/TokyoNight.itermcolors ~/Library/Application\ Support/iTerm2/

# macOS Defaults
osx-defaults:
	@echo "Applying macOS defaults..."
	@defaults write com.apple.finder AppleShowAllFiles -bool true # Show hidden files
	@defaults write NSGlobalDomain NSAutomaticSpellCheckingEnabled -bool false # Disable auto-correct
	@defaults write com.apple.dock autohide -bool true # Auto-hide dock
	@defaults write com.apple.dock tilesize -int 36 # Set dock icon size
	@defaults write NSGlobalDomain KeyRepeat -int 2 # Set key repeat rate
	@defaults write NSGlobalDomain InitialKeyRepeat -int 15 # Set initial key repeat delay
	@killall Finder Dock # Restart affected apps
	@echo "macOS defaults applied successfully!"

# Mac App Store apps
mas:
	@if ! command -v mas >/dev/null 2>&1; then \
		echo "Installing mas-cli..."; \
		brew install mas; \
	fi
	@echo "Installing Mac App Store applications..."
	@mas install 497799835 # Xcode
	@mas install 409203825 # Numbers
	@mas install 409201541 # Pages
	@mas install 409183694 # Keynote
	# Add more apps as needed
	@echo "Mac App Store applications installed!"
