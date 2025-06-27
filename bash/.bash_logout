# ~/.bash_logout
# Executed when a login shell exits

# Clear the screen for security
clear

# Save history
history -a

# Clean up temporary files (optional)
# rm -f ~/.bash_temp_* 2>/dev/null

# Log logout time (optional)
#echo "$(date): Bash session ended" >>~/.bash_logout
#log

# Optional: Clear clipboard on macOS (uncomment if desired)
# if command -v pbcopy >/dev/null 2>&1; then
# echo "" | pbcopy
# fi

# Optional: Lock screen on logout (uncomment if desired)
# if command -v osascript >/dev/null 2>&1; then
#   osascript -e 'tell application "System Events"
# to keystroke "q" using {control down, command down}'
# fi
