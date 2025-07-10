#!/bin/bash

# LVM Disk Resize Script
# Automatically resizes LVM volumes and filesystems after disk expansion

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -d, --device DEVICE    Specify device (e.g., /dev/sda)"
    echo "  -p, --partition NUM    Specify partition number (default: auto-detect)"
    echo "  -v, --volume LV_PATH   Specify logical volume path"
    echo "  -y, --yes             Skip confirmation prompts"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Auto-detect everything"
    echo "  $0 -d /dev/sda -p 2    # Specify device and partition"
    echo "  $0 -y                  # Skip confirmations"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Detect the main disk device
detect_device() {
    local device
    device=$(lsblk -no PKNAME $(findmnt -no SOURCE /) 2>/dev/null | head -1)
    if [[ -n "$device" ]]; then
        echo "/dev/$device"
    else
        echo "/dev/sda"
    fi
}

# Detect LVM partition
detect_lvm_partition() {
    local device="$1"
    local partition

    # First try to get from pvs (most reliable)
    partition=$(pvs --noheadings -o pv_name 2>/dev/null | grep "$device" | tr -d ' ' | sed "s|${device}||" | head -1)

    if [[ -n "$partition" ]]; then
        echo "$partition"
    else
        # Fallback: Look for LVM partitions in fdisk (type 8e)
        partition=$(fdisk -l "$device" 2>/dev/null | grep "8e.*Linux LVM" | awk '{print $1}' | sed "s|${device}||" | head -1)
        if [[ -n "$partition" ]]; then
            echo "$partition"
        else
            echo "5" # Default to partition 5 for logical volumes
        fi
    fi
}

# Detect root logical volume
detect_root_lv() {
    local lv_path
    lv_path=$(findmnt -no SOURCE / 2>/dev/null)
    if [[ "$lv_path" == /dev/mapper/* ]]; then
        echo "$lv_path"
    else
        # Try to find it via LVM commands
        local vg_name lv_name
        vg_name=$(vgs --noheadings -o vg_name 2>/dev/null | tr -d ' ' | head -1)
        lv_name=$(lvs --noheadings -o lv_name "$vg_name" 2>/dev/null | tr -d ' ' | grep -E "(root|lv-root)" | head -1)
        if [[ -n "$vg_name" && -n "$lv_name" ]]; then
            echo "/dev/mapper/${vg_name}-${lv_name}"
        else
            echo ""
        fi
    fi
}

# Show current disk usage
show_current_state() {
    log_info "Current disk usage:"
    df -h / | tail -1

    log_info "Current LVM state:"
    echo "Physical Volumes:"
    pvs
    echo "Volume Groups:"
    vgs
    echo "Logical Volumes:"
    lvs
}

# Check if partition table needs updating
check_partition_table() {
    local device="$1"

    log_info "Checking if partition table needs updating..."

    # Use fdisk to check if the disk has grown
    local disk_size partition_end
    disk_size=$(fdisk -l "$device" 2>/dev/null | grep "Disk $device" | awk '{print $5}')
    partition_end=$(fdisk -l "$device" 2>/dev/null | grep "^${device}[0-9]" | tail -1 | awk '{print $4}')

    if [[ -n "$disk_size" && -n "$partition_end" ]]; then
        log_info "Disk size: $disk_size bytes"
        log_info "Last partition ends at sector: $partition_end"
    fi
}

# Fix partition table using fdisk if needed
fix_partition_table() {
    local device="$1"
    local current_lvm_partition="$2"

    log_info "Checking if partition table needs extension..."

    # Verify the current LVM partition exists
    if [[ ! -b "${device}${current_lvm_partition}" ]]; then
        log_error "Current LVM partition ${device}${current_lvm_partition} not found!"
        log_info "Available partitions:"
        lsblk "$device"
        return 1
    fi

    # Get disk size and last partition end
    local disk_sectors last_partition_end
    disk_sectors=$(fdisk -l "$device" 2>/dev/null | grep "^Disk $device" | awk '{print $7}')
    last_partition_end=$(fdisk -l "$device" 2>/dev/null | grep "^${device}[0-9]" | tail -1 | awk '{print $3}')

    if [[ -n "$disk_sectors" && -n "$last_partition_end" ]]; then
        local available_sectors=$((disk_sectors - last_partition_end - 1))
        if [[ $available_sectors -gt 1000 ]]; then
            log_info "Found $(($available_sectors * 512 / 1024 / 1024))MB of unallocated space"
            log_info "Automatically extending partitions to use all available space..."

            # Get the start sector of the extended partition for recreation
            local extended_start
            extended_start=$(fdisk -l "$device" 2>/dev/null | grep "Extended" | awk '{print $2}')

            if [[ -z "$extended_start" ]]; then
                log_error "Could not find extended partition start sector"
                return 1
            fi

            log_info "Recreating partitions to use full disk space..."

            # Use fdisk to extend partitions automatically
            (
                echo d                      # Delete partition
                echo $current_lvm_partition # Delete current LVM partition
                echo d                      # Delete partition
                echo 2                      # Delete extended partition
                echo n                      # New partition
                echo e                      # Extended
                echo 2                      # Partition number 2
                echo $extended_start        # Use original start sector
                echo                        # Default end (use all space)
                echo n                      # New partition
                echo l                      # Logical
                echo                        # Default start
                echo                        # Default end (use all space)
                echo t                      # Change type
                echo $current_lvm_partition # The logical partition number
                echo 8e                     # Linux LVM
                echo w                      # Write changes
            ) | fdisk "$device" >/dev/null 2>&1

            if [[ $? -eq 0 ]]; then
                log_success "Partitions extended to use full disk"
            else
                log_error "Failed to extend partitions automatically"
                return 1
            fi
        else
            log_info "Partition table already uses full disk space"
        fi
    fi

    # Force kernel to re-read partition table
    partprobe "$device" &>/dev/null || true
    sleep 3 # Give more time for the kernel to process changes

    # Verify the partition still exists after recreation
    if [[ ! -b "${device}${current_lvm_partition}" ]]; then
        log_error "LVM partition ${device}${current_lvm_partition} not found after partition extension!"
        log_info "Waiting for device to appear..."
        sleep 5
        partprobe "$device" &>/dev/null || true

        if [[ ! -b "${device}${current_lvm_partition}" ]]; then
            log_error "Device still not found. You may need to reboot."
            return 1
        fi
    fi

    return 0
}

# Main resize function
resize_lvm() {
    local device="$1"
    local partition="$2"
    local lv_path="$3"
    local skip_confirm="$4"

    log_info "Starting LVM resize process..."
    log_info "Device: $device"
    log_info "Partition: ${device}${partition}"
    log_info "Logical Volume: $lv_path"

    if [[ "$skip_confirm" == "false" ]]; then
        echo
        read -p "Continue with resize? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Resize cancelled"
            exit 0
        fi
    fi

    # Step 1: Check and fix partition table if needed
    check_partition_table "$device"
    if ! fix_partition_table "$device" "$partition"; then
        log_error "Partition table extension required - see instructions above"
        exit 1
    fi

    # Step 2: Grow the partition
    log_info "Growing partition ${device}${partition}..."
    if growpart "$device" "$partition"; then
        log_success "Partition grown successfully"
    else
        log_warning "Partition may already be at maximum size"
    fi

    # Step 3: Resize physical volume
    log_info "Resizing physical volume ${device}${partition}..."
    if pvresize "${device}${partition}"; then
        log_success "Physical volume resized successfully"
    else
        log_error "Failed to resize physical volume"
        exit 1
    fi

    # Step 4: Extend logical volume
    log_info "Extending logical volume $lv_path..."
    if lvextend -l +100%FREE "$lv_path"; then
        log_success "Logical volume extended successfully"
    else
        log_warning "Logical volume may already be at maximum size"
    fi

    # Step 5: Resize filesystem
    log_info "Resizing filesystem on $lv_path..."
    if resize2fs "$lv_path"; then
        log_success "Filesystem resized successfully"
    else
        log_error "Failed to resize filesystem"
        exit 1
    fi

    log_success "LVM resize completed successfully!"
}

# Main function
main() {
    local device=""
    local partition=""
    local lv_path=""
    local skip_confirm="false"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -d | --device)
            device="$2"
            shift 2
            ;;
        -p | --partition)
            partition="$2"
            shift 2
            ;;
        -v | --volume)
            lv_path="$2"
            shift 2
            ;;
        -y | --yes)
            skip_confirm="true"
            shift
            ;;
        -h | --help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        esac
    done

    check_root

    # Auto-detect missing parameters
    if [[ -z "$device" ]]; then
        device=$(detect_device)
        log_info "Auto-detected device: $device"
    fi

    if [[ -z "$partition" ]]; then
        partition=$(detect_lvm_partition "$device")
        log_info "Auto-detected LVM partition: $partition"
    fi

    if [[ -z "$lv_path" ]]; then
        lv_path=$(detect_root_lv)
        if [[ -z "$lv_path" ]]; then
            log_error "Could not detect root logical volume"
            log_error "Please specify with -v option"
            exit 1
        fi
        log_info "Auto-detected logical volume: $lv_path"
    fi

    # Verify the logical volume exists
    if [[ ! -e "$lv_path" ]]; then
        log_error "Logical volume $lv_path does not exist"
        exit 1
    fi

    # Show current state
    show_current_state
    echo

    # Perform the resize
    resize_lvm "$device" "$partition" "$lv_path" "$skip_confirm"

    # Show final state
    echo
    log_info "Final disk usage:"
    df -h / | tail -1
}

# Check for required tools
check_tools() {
    local missing_tools=()

    for tool in growpart pvresize lvextend resize2fs fdisk partprobe; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Install with: apt install cloud-guest-utils lvm2 e2fsprogs util-linux parted"
        exit 1
    fi
}

# Run tool check and main function
check_tools
main "$@"
