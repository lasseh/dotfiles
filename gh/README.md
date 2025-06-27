# GitHub CLI Configuration

This directory contains configuration for the GitHub CLI (`gh`).

## Features

### **Useful Aliases**
- `gh co` - Checkout PR
- `gh pv` - View PR  
- `gh pc` - Create PR
- `gh pm` - Merge PR
- `gh ic` - Create issue
- `gh myissues` - List your assigned issues
- `gh myprs` - List your PRs
- `gh trending` - Show trending repos

### **Settings**
- Uses SSH for git operations
- Vim as default editor
- Interactive prompts enabled
- Less with color support as pager

## Usage

After stowing, authenticate with:
```bash
gh auth login
```

Then use the aliases:
```bash
gh myprs          # List your pull requests
gh myissues       # List your assigned issues  
gh trending       # Show trending repositories
gh co 123         # Checkout PR #123
```