.PHONY: mac-install clean brew brew-bundle brew-dump dotfiles fzf iterm2 osx-defaults help

# Stow related targets
dotfiles:
	@mkdir -p ~/.config
	@stow --no-folding --override=.* -R -t ~/ ack
	@stow --no-folding --override=.* -R -t ~/ bash
	@stow --no-folding --override=.* -R -t ~/ bat
	@stow --no-folding --override=.* -R -t ~/ btop
	@stow --no-folding --override=.* -R -t ~/ ccze
	@stow --no-folding --override=.* -R -t ~/ chromaterm
	@stow --no-folding --override=.* -R -t ~/ curl
	@stow --no-folding --override=.* -R -t ~/ dircolors
	@stow --no-folding --override=.* -R -t ~/ eza
	@stow --no-folding --override=.* -R -t ~/ gh
	@stow --no-folding --override=.* -R -t ~/ gh-dash
	@stow --no-folding --override=.* -R -t ~/ ghostty
	@stow --no-folding --override=.* -R -t ~/ git
	@stow --no-folding --override=.* -R -t ~/ htop
	@stow --no-folding --override=.* -R -t ~/ lazygit
	@stow --no-folding --override=.* -R -t ~/ nvim
	@stow --no-folding --override=.* -R -t ~/ pgcli
	@stow --no-folding --override=.* -R -t ~/ tmux
	@stow --no-folding --override=.* -R -t ~/ vim
	@stow --no-folding --override=.* -R -t ~/ zsh
	@echo "All configurations stowed!"

# Install everything
mac-install: brew brew-bundle dotfiles osx-defaults iterm2
	@echo "All installations completed successfully!"

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
	@echo "Comparing current installations with Brewfile..."
	@brew bundle dump --file=./Brewfile.current --force
	@echo "Checking for duplicates in Brewfile..."
	@if grep -E '^(brew|cask|tap|mas)' ./Brewfile | sort | uniq -d | grep -q .; then \
		echo "❌ Duplicates found in Brewfile:"; \
		grep -E '^(brew|cask|tap|mas)' ./Brewfile | sort | uniq -d; \
		echo ""; \
	else \
		echo "✅ No duplicates found in Brewfile"; \
	fi
	@echo "Comparing package lists (position-independent)..."
	@grep -E '^(brew|cask|tap|mas)' ./Brewfile | sort > ./Brewfile.sorted
	@grep -E '^(brew|cask|tap|mas)' ./Brewfile.current | sort > ./Brewfile.current.sorted
	@if diff -u ./Brewfile.sorted ./Brewfile.current.sorted > /dev/null 2>&1; then \
		echo "✅ Brewfile packages match current installations"; \
		rm ./Brewfile.current ./Brewfile.sorted ./Brewfile.current.sorted; \
	else \
		echo "❌ Package differences found:"; \
		echo ""; \
		diff -u ./Brewfile.sorted ./Brewfile.current.sorted || true; \
		echo ""; \
		echo "Files saved for reference:"; \
		echo "  - Brewfile.current: Current brew dump"; \
		echo "  - Brewfile.sorted: Sorted Brewfile packages"; \
		echo "  - Brewfile.current.sorted: Sorted current packages"; \
		rm ./Brewfile.sorted ./Brewfile.current.sorted; \
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
	@echo "Applying Safari defaults (will close Safari if running)..."
	@./osx/safari.sh
	@echo "All macOS defaults applied successfully!"
	@echo "Restarting affected applications..."
	@killall Finder Dock SystemUIServer 2>/dev/null || true

fzf:
	@echo "Installing fzf..."
	@if ! command -v fzf >/dev/null 2>&1; then \
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
	else \
		echo "fzf is already installed, skipping..."
	fi

## Help display.
## Pulls comments from beside commands and prints a nicely formatted
## display with the commands and their usage information.
.DEFAULT_GOAL := help

help: ## Prints this help
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
