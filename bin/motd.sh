#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Colors – TokyoNight Theme (Storm variant)
reset="\033[0m"
bg="\033[48;5;235m"        # #24283b background
fg="\033[38;5;251m"        # #c0caf5 foreground
title="\033[1;38;5;32m"    # #7dcfff bright blue (title)
label="\033[38;5;162m"     # #a9b1d6 comment/label
value="\033[38;5;35m"      # #9ece6a green
highlight="\033[38;5;203m" # #f7768e red/pink
accent="\033[38;5;221m"    # #e0af68 yellow
secondary="\033[38;5;215m" # #ff9e64 orange
bar_full="\033[38;5;117m"  # #7dcfff blue for filled
bar_empty="\033[38;5;59m"  # #565f89 dark gray for empty
separator="\033[38;5;59m"  # #565f89 for separators

# Draw a usage bar with colon as filler
print_usage_bar() {
    local percent="${1:-0}"
    local bar_length=30
    local filled=$(((percent * bar_length) / 100))
    local empty=$((bar_length - filled))

    # Color coding based on usage
    local bar_color="$bar_full"
    if ((percent >= 80)); then
        bar_color="$highlight" # Red for high usage
    elif ((percent >= 60)); then
        bar_color="$accent" # Yellow for medium usage
    fi

    printf "["

    # Draw the filled portion with # characters
    if ((filled > 0)); then
        # If the bar is completely full (100%), draw all # characters
        if ((filled == bar_length)); then
            printf "${bar_color}%0.s#${reset}" $(seq 1 "$filled" 2>/dev/null || true)
        else
            # Draw all but the last as #
            if ((filled > 1)); then
                printf "${bar_color}%0.s#${reset}" $(seq 1 "$((filled - 1))" 2>/dev/null || true)
            fi
            # The last character is a colon (the indicator)
            printf ":"
        fi
    fi

    # Draw the empty portion with non-colored colons
    if ((empty > 0)); then
        printf "%0.s:" $(seq 1 "$empty" 2>/dev/null || true)
    fi

    printf "] ${bar_color}%3s%%${reset}" "$percent"
}

# Get system uptime in human-readable format
get_uptime() {
    local uptime_seconds=$(awk '{print int($1)}' /proc/uptime || echo 0)
    local days=$((uptime_seconds / 86400))
    local hours=$(((uptime_seconds % 86400) / 3600))
    local minutes=$(((uptime_seconds % 3600) / 60))

    if ((days > 0)); then
        printf "%dd %dh %dm" "$days" "$hours" "$minutes"
    elif ((hours > 0)); then
        printf "%dh %dm" "$hours" "$minutes"
    else
        printf "%dm" "$minutes"
    fi
}

# Get kernel version
kernel_version=$(uname -r || echo "unknown")

# Header info
hostname=$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "localhost")
current_date=$(date +"%a %b %d %Y %H:%M:%S")
uptime=$(get_uptime)

# CPU info
cpu_model=$(lscpu | grep -E "^Model name:" | sed 's/Model name:[ ]*//' | sed 's/  */ /g' || echo "Unknown")
if [[ -z "$cpu_model" ]] || [[ "$cpu_model" == "Unknown" ]]; then
    # Fallback for systems that use "Model:" instead, but exclude BIOS
    cpu_model=$(lscpu | grep -E "^Model:" | grep -v "BIOS" | sed 's/Model:[ ]*//' | sed 's/  */ /g' || echo "Unknown")
fi
cpu_cores=$(nproc || echo 1)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' || echo 0)
cpu_load=$(awk '{ printf "%.2f", $1 }' /proc/loadavg || echo "0.00")

# Memory info
mem_total=$(free -b | awk '/^Mem:/ {print $2}' || echo 0)
mem_used=$(free -b | awk '/^Mem:/ {print $3}' || echo 0)
mem_available=$(free -b | awk '/^Mem:/ {print $7}' || echo 0)
mem_cached=$(free -b | awk '/^Mem:/ {print $6}' || echo 0)

# Convert to MB for display
mem_total_mb=$((mem_total / 1024 / 1024))
mem_used_mb=$((mem_used / 1024 / 1024))
mem_available_mb=$((mem_available / 1024 / 1024))
mem_cached_mb=$((mem_cached / 1024 / 1024))

memory_usage_pct=$(((mem_used * 100) / (mem_total == 0 ? 1 : mem_total)))

# Swap info
swap_total=$(free -b | awk '/^Swap:/ {print $2}' || echo 0)
swap_used=$(free -b | awk '/^Swap:/ {print $3}' || echo 0)
swap_total_mb=$((swap_total / 1024 / 1024))
swap_used_mb=$((swap_used / 1024 / 1024))

if ((swap_total == 0)); then
    swap_usage_pct=0
else
    swap_usage_pct=$(((swap_used * 100) / swap_total))
fi

# Disk usage for multiple mount points
get_disk_usage() {
    df -h | grep -E '^/dev/' | while read -r line; do
        local filesystem=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $2}')
        local used=$(echo "$line" | awk '{print $3}')
        local avail=$(echo "$line" | awk '{print $4}')
        local use_pct=$(echo "$line" | awk '{print $5}' | tr -d '%')
        local mount=$(echo "$line" | awk '{print $6}')

        printf "${label}%-15s${reset} ${secondary}%-6s${reset} " "$mount" "$size"
        print_usage_bar "$use_pct"
        printf " ${value}%s${reset} used, ${fg}%s${reset} avail\n" "$used" "$avail"
    done
}

# OS detection
if [[ -f /etc/os-release ]]; then
    os=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
else
    os="$(uname -s) $(uname -r)"
fi

# Network interfaces
get_ip_info() {
    for intf in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo || true); do
        local state ipv4 ipv6
        state=$(cat "/sys/class/net/$intf/operstate" 2>/dev/null || echo "unknown")
        ipv4=$(ip -4 -o addr show "$intf" | awk '{print $4}' | cut -d/ -f1 || true)
        ipv6=$(ip -6 -o addr show "$intf" | awk '{print $4}' | grep -v '^fe80' | cut -d/ -f1 | head -1 || true)

        if [[ -n "$ipv4" || -n "$ipv6" ]]; then
            local state_color="$highlight"
            [[ "$state" == "up" ]] && state_color="$value"

            printf "  ${secondary}%-10s${reset} ${state_color}%-8s${reset}" "$intf" "$state"
            [[ -n "$ipv4" ]] && printf " ${value}%-15s${reset}" "$ipv4"
            [[ -n "$ipv6" ]] && printf " ${value}%s${reset}" "$ipv6"
            printf "\n"
        fi
    done
}

# Check if sudo is available without password
can_sudo_nopasswd() {
    sudo -n true 2>/dev/null
}

# Check for recent critical system errors
check_system_errors() {
    local found_errors=false
    local max_errors=5
    local use_sudo=false
    
    # Check if we can use sudo without password
    if can_sudo_nopasswd; then
        use_sudo=true
    fi

    # Try journald first (systemd systems)
    if command -v journalctl &>/dev/null; then
        local errors=""
        
        # Try without sudo first
        local test_journal=$(journalctl -n 1 2>&1)
        if [[ ! "$test_journal" =~ "Permission denied" ]] && [[ ! "$test_journal" =~ "No journal files" ]]; then
            # Get critical errors from last 24 hours - use --output=cat to get just messages
            errors=$(journalctl --since "24 hours ago" -p 0..3 --no-pager --output=cat 2>/dev/null | tail -$max_errors)
        elif $use_sudo; then
            # Try with sudo if regular access failed and sudo is available
            errors=$(sudo journalctl --since "24 hours ago" -p 0..3 --no-pager --output=cat 2>/dev/null | tail -$max_errors)
        fi

        if [[ -n "$errors" ]]; then
            printf "\n${title}Recent System Errors${reset} ${fg}(last 24h)${reset}\n"
            printf "${separator}%0.s─" $(seq 1 $box_width)
            printf "${reset}\n"
            found_errors=true

                while IFS= read -r line; do
                    if [[ -n "$line" ]]; then
                        printf "  ${highlight}%s${reset}\n" "$line"
                    fi
                done <<<"$errors"
        fi
    fi

    # Fallback to traditional syslog files
    if ! $found_errors; then
        local syslog_files=("/var/log/syslog" "/var/log/messages" "/var/log/kern.log")

        for log_file in "${syslog_files[@]}"; do
            if [[ -r "$log_file" ]]; then
                # Look for error patterns in recent entries
                local errors=$(tail -500 "$log_file" 2>/dev/null | grep -iE "(error|critical|fatal|panic|fail)" | grep -v "UFW BLOCK" | tail -$max_errors)

                if [[ -n "$errors" ]]; then
                    printf "\n${title}Recent System Errors${reset} ${fg}(from %s)${reset}\n" "$(basename "$log_file")"
                    printf "${separator}%0.s─" $(seq 1 $box_width)
                    printf "${reset}\n"
                    found_errors=true

                    while IFS= read -r line; do
                        if [[ -n "$line" ]]; then
                            # Extract just the message part
                            # Format is typically: Month Day Time Hostname Process[PID]: Message
                            local msg=$(echo "$line" | sed -E 's/^[A-Za-z]+[[:space:]]+[0-9]+[[:space:]]+[0-9:]+[[:space:]]+[^[:space:]]+[[:space:]]+//')
                            printf "  ${highlight}%s${reset}\n" "$msg"
                        fi
                    done <<<"$errors"
                fi
                break # Only check one syslog file
            fi
        done
    fi

    # Try dmesg as last resort
    if ! $found_errors && command -v dmesg &>/dev/null; then
        # Check for kernel errors
        local dmesg_output=$(dmesg -l err,crit,alert,emerg 2>/dev/null | tail -$max_errors || true)
        
        # If no output and sudo is available, try with sudo
        if [[ -z "$dmesg_output" ]] && $use_sudo; then
            dmesg_output=$(sudo dmesg -l err,crit,alert,emerg 2>/dev/null | tail -$max_errors || true)
        fi

        if [[ -n "$dmesg_output" ]]; then
            printf "\n${title}Recent Kernel Errors${reset} ${fg}(from dmesg)${reset}\n"
            printf "${separator}%0.s─" $(seq 1 $box_width)
            printf "${reset}\n"
            found_errors=true

            while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    # Remove timestamp [xxx.xxxx] from dmesg output
                    local msg=$(echo "$line" | sed -E 's/^\[[[:space:]]*[0-9.]+\][[:space:]]*//')
                    printf "  ${highlight}%s${reset}\n" "$msg"
                fi
            done <<<"$dmesg_output"
        fi
    fi

    if ! $found_errors; then
        # Check if we can access any logs at all
        local can_access_logs=false
        
        # Check journalctl access
        if command -v journalctl &>/dev/null; then
            local test_journal=$(journalctl -n 1 2>&1)
            if [[ ! "$test_journal" =~ "Permission denied" ]] && [[ ! "$test_journal" =~ "No journal files" ]]; then
                can_access_logs=true
            fi
        fi
        
        # Check traditional log files
        if [[ -r "/var/log/syslog" ]] || [[ -r "/var/log/messages" ]] || [[ -r "/var/log/kern.log" ]]; then
            can_access_logs=true
        fi
        
        # Check dmesg access
        if command -v dmesg &>/dev/null && dmesg -l err 2>/dev/null >/dev/null; then
            can_access_logs=true
        fi
        
        if $can_access_logs; then
            printf "\n${title}System Errors${reset}\n"
            printf "${separator}%0.s─" $(seq 1 $box_width)
            printf "${reset}\n"
            printf "  ${value}✓ No critical errors found in recent logs${reset}\n"
        else
            printf "\n${title}System Errors${reset}\n"
            printf "${separator}%0.s─" $(seq 1 $box_width)
            printf "${reset}\n"
            printf "  ${fg}ℹ Log access requires elevated privileges${reset}\n"
        fi
    fi
}

# Output
# clear

# Calculate proper spacing for the header
header_text="System Information for $hostname"
header_length=${#header_text}
box_width=$((header_length + 4))

# Create the box with proper width
printf "\n${title}"
printf "╔"
printf "%0.s═" $(seq 1 $box_width)
printf "╗"
printf "${reset}\n"

printf "${title}║${reset} ${title}%-*s${reset} ${title}║${reset}\n" "$((box_width - 2))" "$header_text"

printf "${title}╚"
printf "%0.s═" $(seq 1 $box_width)
printf "╝"
printf "${reset}\n\n"

printf "${title}System${reset}\n"
printf "${separator}%0.s─" $(seq 1 $box_width)
printf "${reset}\n"
printf "${label}%-15s${reset}: ${value}%s${reset}\n" "OS" "$os"
printf "${label}%-15s${reset}: ${value}%s${reset}\n" "Kernel" "$kernel_version"
printf "${label}%-15s${reset}: ${value}%s${reset}\n" "Uptime" "$uptime"

printf "\n${title}CPU${reset}\n"
printf "${separator}%0.s─" $(seq 1 $box_width)
printf "${reset}\n"
printf "${label}%-15s${reset}: ${value}%s${reset}\n" "Model" "$cpu_model"
printf "${label}%-15s${reset}: ${value}%d cores${reset}\n" "Cores" "$cpu_cores"
printf "${label}%-15s${reset}: ${value}%.1f%% ${reset}(load avg: ${secondary}%.2f${reset})\n" "Usage" "$cpu_usage" "$cpu_load"

printf "\n${title}Memory${reset}\n"
printf "${separator}%0.s─" $(seq 1 $box_width)
printf "${reset}\n"
printf "${label}%-15s${reset}: " "RAM"
print_usage_bar "$memory_usage_pct"
printf " ${value}%'d MB${reset} / ${fg}%'d MB${reset}\n" "$mem_used_mb" "$mem_total_mb"

if ((swap_total > 0)); then
    printf "${label}%-15s${reset}: " "Swap"
    print_usage_bar "$swap_usage_pct"
    printf " ${value}%'d MB${reset} / ${fg}%'d MB${reset}\n" "$swap_used_mb" "$swap_total_mb"
fi

printf "\n${title}Disk Usage${reset}\n"
printf "${separator}%0.s─" $(seq 1 $box_width)
printf "${reset}\n"
get_disk_usage

printf "\n${title}Network${reset}\n"
printf "${separator}%0.s─" $(seq 1 $box_width)
printf "${reset}\n"
get_ip_info

# Check for recent critical system errors
check_system_errors

# Check for reboot requirement
if [ -x /usr/share/unattended-upgrades/update-motd-unattended-upgrades ]; then
    printf "\n${title}System Updates${reset}\n"
    printf "${separator}%0.s─" $(seq 1 $box_width)
    printf "${reset}\n"
    /usr/share/unattended-upgrades/update-motd-unattended-upgrades
fi

printf "\n"
