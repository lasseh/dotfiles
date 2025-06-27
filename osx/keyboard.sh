#!/bin/bash

echo "Configuring Keyboard..."

# Set a blazingly fast keyboard repeat rate
# Current: KeyRepeat=2, InitialKeyRepeat=15 - MATCHES CURRENT SETTINGS
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys in favor of key repeat
# Current: ApplePressAndHoldEnabled=0 (disabled) - MATCHES
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable automatic capitalization as it's annoying when typing code
# Current: NSAutomaticCapitalizationEnabled=1 (enabled) - NEEDS UPDATE
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they're annoying when typing code  
# Current: NSAutomaticDashSubstitutionEnabled=0 (disabled) - MATCHES
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it's annoying when typing code
# Current: NSAutomaticPeriodSubstitutionEnabled=1 (enabled) - NEEDS UPDATE
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they're annoying when typing code
# Current: NSAutomaticQuoteSubstitutionEnabled=0 (disabled) - MATCHES
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
# Current: NSAutomaticSpellingCorrectionEnabled=0 (disabled) - MATCHES
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

echo "Keyboard configuration complete"