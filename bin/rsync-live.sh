#!/bin/bash
# continuous-rsync.sh: Continuously synchronizes the source directory to the destination directory.
#
# Usage:
#   ./rsync-live.sh /path/to/source /path/to/destination
#
# Description:
#   This script runs rsync repeatedly with a 1-second delay between runs.
#   If you prefer an event-driven approach (on Linux), consider using inotifywait.

# Validate input parameters.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

SRC_DIR="$1"
DEST_DIR="$2"

echo "Starting continuous rsync from '${SRC_DIR}' to '${DEST_DIR}'. Press Ctrl-C to stop."

while true; do
    rsync -av "$SRC_DIR" "$DEST_DIR"
    # Pause briefly to prevent overloading the system if no changes occur.
    sleep 1
done
