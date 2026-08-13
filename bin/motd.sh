#!/usr/bin/env bash
# Login banner. Runs in the login path as the logging-in user, so it must never
# abort mid-render: no `set -e`, and every section degrades to a message.
set -uo pipefail
IFS=$'\n\t'

# Colors – TokyoNight Theme (Storm variant)
reset=$'\033[0m'
fg=$'\033[38;5;251m'        # #c0caf5 foreground
title=$'\033[1;38;5;32m'    # #7dcfff bright blue (title)
label=$'\033[38;5;162m'     # #a9b1d6 comment/label
value=$'\033[38;5;35m'      # #9ece6a green
highlight=$'\033[38;5;203m' # #f7768e red/pink
accent=$'\033[38;5;221m'    # #e0af68 yellow
secondary=$'\033[38;5;215m' # #ff9e64 orange
bar_full=$'\033[38;5;117m'  # #7dcfff blue for filled
separator=$'\033[38;5;59m'  # #565f89 for separators

# How far back to look for errors, and how many to show
error_window="24 hours ago"
max_errors=5

# Repeat a character n times. Parameter expansion keeps this multibyte-safe
# (`tr` would corrupt ─) and avoids a seq/subshell per separator line.
repeat_char() {
    local n="$1" char="$2" pad
    ((n <= 0)) && return 0
    printf -v pad '%*s' "$n" ''
    printf '%s' "${pad// /$char}"
}

# Horizontal rule matching the header box width
hr() {
    printf '%s%s%s\n' "$separator" "$(repeat_char "$box_width" '─')" "$reset"
}

# Section heading + rule. $2 is an optional dimmed suffix.
section() {
    printf '\n%s%s%s' "$title" "$1" "$reset"
    (($# > 1)) && printf ' %s%s%s' "$fg" "$2" "$reset"
    printf '\n'
    hr
}

# Draw a usage bar with colon as filler
print_usage_bar() {
    local percent="${1:-0}"
    local bar_length=30
    ((percent < 0)) && percent=0
    ((percent > 100)) && percent=100
    local filled=$(((percent * bar_length) / 100))
    local empty=$((bar_length - filled))

    # Color coding based on usage
    local bar_color="$bar_full"
    if ((percent >= 80)); then
        bar_color="$highlight" # Red for high usage
    elif ((percent >= 60)); then
        bar_color="$accent" # Yellow for medium usage
    fi

    printf '['
    if ((filled == bar_length)); then
        printf '%s%s%s' "$bar_color" "$(repeat_char "$filled" '#')" "$reset"
    elif ((filled > 1)); then
        # All but the last as #, the last is a colon (the indicator)
        printf '%s%s%s:' "$bar_color" "$(repeat_char "$((filled - 1))" '#')" "$reset"
    elif ((filled == 1)); then
        printf ':'
    fi
    repeat_char "$empty" ':'
    printf '] %s%3s%%%s' "$bar_color" "$percent" "$reset"
}

# Get system uptime in human-readable format
get_uptime() {
    local uptime_seconds
    uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null) || uptime_seconds=0
    local days=$((uptime_seconds / 86400))
    local hours=$(((uptime_seconds % 86400) / 3600))
    local minutes=$(((uptime_seconds % 3600) / 60))

    if ((days > 0)); then
        printf '%dd %dh %dm' "$days" "$hours" "$minutes"
    elif ((hours > 0)); then
        printf '%dh %dm' "$hours" "$minutes"
    else
        printf '%dm' "$minutes"
    fi
}

# Header info
kernel_version=$(uname -r 2>/dev/null) || kernel_version="unknown"
hostname=$(hostname -f 2>/dev/null || hostname 2>/dev/null) || hostname="localhost"
uptime=$(get_uptime)

header_text="System Information for $hostname"
box_width=$((${#header_text} + 4))

# CPU info. lscpu reports "-" for Model on some ARM hosts, so fall back to
# /proc/cpuinfo, which carries the real name there.
cpu_model=$(lscpu 2>/dev/null | awk -F': +' '/^Model name:/ {print $2; exit}')
if [[ -z "$cpu_model" || "$cpu_model" == "-" ]]; then
    cpu_model=$(awk -F': +' '/^model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null)
fi
if [[ -z "$cpu_model" || "$cpu_model" == "-" ]]; then
    cpu_model=$(awk -F': +' '/^Hardware/ {print $2; exit}' /proc/cpuinfo 2>/dev/null)
fi
[[ -z "$cpu_model" ]] && cpu_model="Unknown"

cpu_cores=$(nproc 2>/dev/null) || cpu_cores=1
IFS=' ' read -r load1 load5 load15 _ </proc/loadavg 2>/dev/null || {
    load1=0.00
    load5=0.00
    load15=0.00
}

# Memory info
IFS=' ' read -r mem_total mem_used < <(free -b 2>/dev/null | awk '/^Mem:/ {print $2, $3}') ||
    { mem_total=0 mem_used=0; }
mem_total_mb=$((mem_total / 1024 / 1024))
mem_used_mb=$((mem_used / 1024 / 1024))
memory_usage_pct=$(((mem_used * 100) / (mem_total == 0 ? 1 : mem_total)))

# Swap info
IFS=' ' read -r swap_total swap_used < <(free -b 2>/dev/null | awk '/^Swap:/ {print $2, $3}') ||
    { swap_total=0 swap_used=0; }
swap_total_mb=$((swap_total / 1024 / 1024))
swap_used_mb=$((swap_used / 1024 / 1024))
if ((swap_total == 0)); then
    swap_usage_pct=0
else
    swap_usage_pct=$(((swap_used * 100) / swap_total))
fi

# OS detection
if [[ -f /etc/os-release ]]; then
    os=$(awk -F= '/^PRETTY_NAME=/ {gsub(/"/, "", $2); print $2; exit}' /etc/os-release)
else
    os="$(uname -s) $(uname -r)"
fi
[[ -z "$os" ]] && os="unknown"

# Disk usage for multiple mount points. -P forces one line per filesystem;
# without it long device names (LVM, /dev/mapper/...) wrap and break the columns.
get_disk_usage() {
    local size used avail use_pct mount
    df -P -h 2>/dev/null | awk 'NR > 1 && $1 ~ /^\/dev\//' | while read -r line; do
        IFS=' ' read -r _ size used avail use_pct mount <<<"$line"
        use_pct="${use_pct%\%}"

        printf '%s%-15s%s %s%-6s%s ' "$label" "$mount" "$reset" "$secondary" "$size" "$reset"
        print_usage_bar "$use_pct"
        printf ' %s%s%s used, %s%s%s avail\n' "$value" "$used" "$reset" "$fg" "$avail" "$reset"
    done
}

# Network interfaces
get_ip_info() {
    local intf state ipv4 ipv6 state_color
    # `ip -o link` renders veth/VLAN peers as "eth0@if852"; strip the @-suffix
    # or every /sys and `ip addr` lookup below misses.
    for intf in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | sed 's/@.*//'); do
        case "$intf" in
        lo | veth* | docker* | br-*) continue ;;
        esac

        state=$(cat "/sys/class/net/$intf/operstate" 2>/dev/null) || state="unknown"
        ipv4=$(ip -4 -o addr show "$intf" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1)
        ipv6=$(ip -6 -o addr show "$intf" 2>/dev/null | awk '{print $4}' | grep -v '^fe80' | cut -d/ -f1 | head -1)

        if [[ -n "$ipv4" || -n "$ipv6" ]]; then
            state_color="$highlight"
            [[ "$state" == "up" ]] && state_color="$value"

            printf '  %s%-10s%s %s%-8s%s' "$secondary" "$intf" "$reset" "$state_color" "$state" "$reset"
            [[ -n "$ipv4" ]] && printf ' %s%-15s%s' "$value" "$ipv4" "$reset"
            [[ -n "$ipv6" ]] && printf ' %s%s%s' "$value" "$ipv6" "$reset"
            printf '\n'
        fi
    done
}

# Can we actually read the *system* journal?
#
# journalctl exits 0 and prints "-- No entries --" for an unprivileged user who
# can only see their own journal, so neither its exit code nor its output can be
# used to detect access. Checking the euid/groups systemd grants access to is the
# only reliable test, and it keeps this locale-independent.
journal_accessible() {
    ((EUID == 0)) && return 0
    id -nG 2>/dev/null | grep -qwE 'systemd-journal|adm|wheel'
}

# Recent system errors. journald already ingests kernel messages, so this covers
# what the old dmesg branch did -- but bounded to $error_window, instead of
# replaying boot-time firmware errors on every single login forever.
check_system_errors() {
    section "System Errors" "(last 24h)"

    if ! command -v journalctl >/dev/null 2>&1; then
        printf '  %sℹ journald is not installed on this host%s\n' "$fg" "$reset"
        return 0
    fi

    if [[ ! -d /run/log/journal && ! -d /var/log/journal ]]; then
        printf '  %sℹ no systemd journal on this host%s\n' "$fg" "$reset"
        return 0
    fi

    if ! journal_accessible; then
        printf '  %sℹ system journal not readable — add this user to the '\''adm'\'' group%s\n' "$fg" "$reset"
        return 0
    fi

    # LC_ALL=C pins journalctl's own banner lines ("-- No entries --",
    # "-- Journal begins at ... --") to a known form so they can be dropped;
    # otherwise they render as if they were errors.
    local errors
    errors=$(LC_ALL=C journalctl --system --since "$error_window" --priority=err \
        --no-pager --no-hostname --output=short-iso 2>/dev/null |
        grep -v '^-- .* --$' | tail -n "$max_errors")

    if [[ -z "$errors" ]]; then
        printf '  %s✓ No errors in the system journal%s\n' "$value" "$reset"
        return 0
    fi

    while IFS= read -r line; do
        [[ -n "$line" ]] && printf '  %s%s%s\n' "$highlight" "$line" "$reset"
    done <<<"$errors"
}

# Output

printf '\n%s%s%s%s%s\n' "$title" '╔' "$(repeat_char "$box_width" '═')" '╗' "$reset"
printf '%s║%s %s%-*s%s %s║%s\n' \
    "$title" "$reset" "$title" "$((box_width - 2))" "$header_text" "$reset" "$title" "$reset"
printf '%s%s%s%s%s\n' "$title" '╚' "$(repeat_char "$box_width" '═')" '╝' "$reset"

section "System"
printf '%s%-15s%s: %s%s%s\n' "$label" "OS" "$reset" "$value" "$os" "$reset"
printf '%s%-15s%s: %s%s%s\n' "$label" "Kernel" "$reset" "$value" "$kernel_version" "$reset"
printf '%s%-15s%s: %s%s%s\n' "$label" "Uptime" "$reset" "$value" "$uptime" "$reset"

section "CPU"
printf '%s%-15s%s: %s%s%s\n' "$label" "Model" "$reset" "$value" "$cpu_model" "$reset"
printf '%s%-15s%s: %s%d cores%s\n' "$label" "Cores" "$reset" "$value" "$cpu_cores" "$reset"
printf '%s%-15s%s: %s%s %s %s%s (1m, 5m, 15m)\n' \
    "$label" "Load avg" "$reset" "$secondary" "$load1" "$load5" "$load15" "$reset"

section "Memory"
printf '%s%-15s%s: ' "$label" "RAM" "$reset"
print_usage_bar "$memory_usage_pct"
printf " %s%'d MB%s / %s%'d MB%s\n" "$value" "$mem_used_mb" "$reset" "$fg" "$mem_total_mb" "$reset"

if ((swap_total > 0)); then
    printf '%s%-15s%s: ' "$label" "Swap" "$reset"
    print_usage_bar "$swap_usage_pct"
    printf " %s%'d MB%s / %s%'d MB%s\n" "$value" "$swap_used_mb" "$reset" "$fg" "$swap_total_mb" "$reset"
fi

section "Disk Usage"
get_disk_usage

section "Network"
get_ip_info

check_system_errors

# Pending unattended-upgrades. Debian does ship this helper, but it exits 0 with
# no output on a host with nothing to report -- the old code printed the heading
# unconditionally, so a bare header and rule showed up on every login. Only draw
# the section when the helper actually has something to say.
if [[ -x /usr/share/unattended-upgrades/update-motd-unattended-upgrades ]]; then
    updates=$(/usr/share/unattended-upgrades/update-motd-unattended-upgrades 2>/dev/null)
    if [[ -n "$updates" ]]; then
        section "System Updates"
        while IFS= read -r line; do
            [[ -n "$line" ]] && printf '  %s%s%s\n' "$accent" "$line" "$reset"
        done <<<"$updates"
    fi
fi

printf '\n'
