#!/bin/bash

echo "Configuring Dock..."

# Auto-hide the Dock (current: enabled)
defaults write com.apple.dock autohide -bool true

# Set the icon size of Dock items to 32 pixels (current setting)
defaults write com.apple.dock tilesize -int 32

# Set large size for magnification to 16 pixels (current setting)
defaults write com.apple.dock largesize -int 16

# Change minimize/maximize window effect to scale (current setting)
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application's icon (current: enabled)
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items (current: enabled)
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock (current: enabled)
defaults write com.apple.dock show-process-indicators -bool true

# Don't animate opening applications from the Dock (current: disabled)
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations (current: 0.1)
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't group windows by application in Mission Control (current: disabled)
defaults write com.apple.dock expose-group-by-app -bool false

# Don't show Dashboard as a Space (current: enabled)
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don't automatically rearrange Spaces based on most recent use (current: disabled)
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay (current: 0)
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock (current: 0)
defaults write com.apple.dock autohide-time-modifier -float 0

# Don't show recent applications in Dock (current: disabled)
defaults write com.apple.dock show-recents -bool false

# Disable Mission Control gesture (current: disabled)
defaults write com.apple.dock showMissionControlGestureEnabled -bool false

# Disable Show Desktop gesture (current: disabled)
defaults write com.apple.dock showDesktopGestureEnabled -bool false

# Hot corners - Top right and bottom right corners set to Mission Control
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 1048576
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 1048576

echo "Dock configuration complete"