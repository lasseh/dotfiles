# CCZE Configuration - TokyoNight Night Theme

CCZE (C Colorize) is a log colorizer configured with TokyoNight Night theme colors for consistent visual experience across your terminal.

## Installation

```bash
brew install ccze
```

## Configuration Files

- `.ccze/cczerc` - Main color configuration (TokyoNight Night theme)
- `.ccze/cczepluginrc` - Plugin enable/disable settings

## TokyoNight Night Color Scheme

This configuration uses the TokyoNight Night palette:
- **Background**: `#1a1b26` (dark blue-black)
- **Foreground**: `#c0caf5` (light blue-white)
- **Blue**: `#7aa2f7` (bright blue)
- **Cyan**: `#7dcfff` (bright cyan)
- **Green**: `#9ece6a` (bright green)
- **Yellow**: `#e0af68` (warm yellow)
- **Red**: `#f7768e` (bright red)
- **Purple**: `#bb9af7` (bright purple)

## Usage Examples

### Basic log colorization
```bash
tail -f /var/log/system.log | ccze -A
```

### Network device logs (as used in your aliases)
```bash
ssh router 'show log' | ccze -A
```

### Custom network log monitoring (from your yolotail alias)
```bash
ssh nms.as207788.net 'tail -n 0 -qf /var/log/network/c*.log | ccze -A'
```

## TokyoNight Color Mapping

### Network Engineering Elements
- **IP Addresses**: Blue bold (`#7aa2f7`) - matches TokyoNight blue
- **Ports**: Cyan bold (`#7dcfff`) - bright cyan for visibility
- **Protocols**: Blue (`#7aa2f7`) - consistent with IP addresses
- **Interfaces**: Green bold (`#9ece6a`) - TokyoNight green
- **VLANs**: Yellow (`#e0af68`) - warm yellow
- **BGP/OSPF**: Cyan/Purple bold - protocol distinction

### Log Severity Levels
- **Debug**: White (`#c0caf5`) - normal foreground
- **Info**: Green (`#9ece6a`) - positive indication
- **Warning**: Yellow bold (`#e0af68`) - attention needed
- **Error**: Red bold (`#f7768e`) - TokyoNight red
- **Critical**: Red bold + effects - maximum visibility

### System Elements
- **Timestamps**: Cyan bold (`#7dcfff`) - easy time scanning
- **Hostnames**: Green bold (`#9ece6a`) - device identification
- **Processes**: Yellow bold (`#e0af68`) - process distinction
- **Services**: Blue bold (`#7aa2f7`) - service identification

## Integration with Your Workflow

Your existing aliases already use ccze:
- `yolotail` - Network log monitoring
- `cssh()` function - SSH with colorized output
- `mcom()` function - Serial console with colors

## Advanced Usage

### Custom log patterns
You can create custom ccze plugins for specific network device formats (Cisco, Juniper, etc.)

### Performance
Use `-A` flag for ANSI output when piping to other tools or terminals that support it.