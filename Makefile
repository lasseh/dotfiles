.PHONY: all install clean brew brew-bundle brew-dump stow-all dotfiles stow-git stow-vim stow-zsh stow-tmux stow-dircolors stow-btop stow-htop stow-lazygit stow-chromaterm stow-iterm2 osx-defaults mas-install check

# Install everything
mac-install: brew brew-bundle dotfiles osx-defaults mas-install iterm2 fzf
	@echo "All installations completed successfully!"

# Clean up
clean:
	@echo "Removing symlinks..."
	@stow -D git vim zsh tmux dircolors btop htop lazygit chromaterm iterm2 2>/dev/null || true
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
dotfiles:
	@stow -R -t ~/ bash
	@stow -R -t ~/ git
	@stow -R -t ~/ vim
	@stow -R -t ~/ zsh
	@stow -R -t ~/ tmux
	@stow -R -t ~/ dircolors
	@stow -R -t ~/ btop
	@stow -R -t ~/ htop
	@stow -R -t ~/ ssh
	@stow -R -t ~/ lazygit
	@stow -R -t ~/ chromaterm
	@stow -R -t ~/ gh-dash
	@echo "All configurations stowed!"

fzf:
	@echo "Installing fzf..."
	@if ! command -v fzf >/dev/null 2>&1; then \
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
	else \
		echo "fzf is already installed, skipping..."
	fi

iterm2:
	@if defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null | grep -q "$(PWD)/iterm2"; then \
		echo "iTerm2 already configured to use dotfiles folder, skipping..."; \
	else \
		echo "Configuring iTerm2 to use dotfiles folder..."; \
		defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$(PWD)/iterm2"; \
		defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true; \
		echo "Importing Tokyo Night color scheme..."; \
		open "$(PWD)/iterm2/TokyoNight.itermcolors"; \
		echo "iTerm2 will need to be restarted to load settings from custom folder"; \
	fi

# macOS Defaults
osx-defaults:
	@echo "Applying system defaults..."
	@./osx/system.sh
	@echo "Applying Finder defaults..."
	@./osx/finder.sh
	@echo "Applying Dock defaults..."
	@./osx/dock.sh
	@echo "Applying keyboard defaults..."
	@./osx/keyboard.sh
	@echo "Applying trackpad defaults..."
	@./osx/trackpad.sh
	@echo "Applying Safari defaults..."
	@./osx/safari.sh
	@echo "Applying Terminal defaults..."
	@./osx/terminal.sh
	@echo "All macOS defaults applied successfully!"
	@echo "Restarting affected applications..."
	@killall Finder Dock SystemUIServer 2>/dev/null || true

# Mac App Store apps
mas-install:
	@if ! command -v mas >/dev/null 2>&1; then \
		echo "Installing mas-cli..."; \
		brew install mas; \
	fi
	@echo "Installing Mac App Store applications..."
	@mas install 937984704 # Amphetamine
	@mas install 1475387142 # Tailscale
	@mas install 1451685025  # Wireguard
	@echo "Mac App Store applications installed!"

## Help display.
## Pulls comments from beside commands and prints a nicely formatted
## display with the commands and their usage information.
.DEFAULT_GOAL := help

help: ## Prints this help
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
