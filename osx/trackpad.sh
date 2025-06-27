#!/bin/bash

echo "Configuring Trackpad..."

# Trackpad: enable tap to click for this user and for the login screen
# Current: Bluetooth Clicking=1, Global tapBehavior=1 - MATCHES
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Built-in trackpad: enable tap to click
# Current: Built-in Clicking=1 - MATCHES
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Trackpad: disable corner right-click (current setting)
# Current: TrackpadCornerSecondaryClick=0 - NEEDS UPDATE (script sets to 2)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0

# Trackpad: enable right-click
# Current: TrackpadRightClick=1 - MATCHES
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Current host trackpad settings
# Current: trackpadCornerClickBehavior=1, enableSecondaryClick=1 - MATCHES
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Enable three finger drag
# Current: TrackpadThreeFingerDrag=0 - NEEDS UPDATE (not in original script)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

# Disable two finger double tap (smart zoom)
# Current: TrackpadTwoFingerDoubleTapGesture=1 - NEEDS UPDATE
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 0

# Disable notification center gesture  
# Current: TrackpadTwoFingerFromRightEdgeSwipeGesture=3 - NEEDS UPDATE
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 0

# Keep "natural" (Lion-style) scrolling enabled (current preference)
# Current: com.apple.swipescrolldirection=1 - NEEDS UPDATE (script disables it)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Increase sound quality for Bluetooth headphones/headsets
# Current: Apple Bitpool Min=40 - MATCHES
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
# Current: AppleKeyboardUIMode=3 - MATCHES
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Accessibility zoom settings (optional - not currently configured)
# defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

echo "Trackpad configuration complete"