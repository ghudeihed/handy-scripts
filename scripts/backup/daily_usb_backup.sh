#!/bin/bash

# Variables
SOURCE="/"
BACKUP_MOUNT_POINT="/media/nyx/BACKUP_USB"
BACKUP_DIR="$BACKUP_MOUNT_POINT/daily_backup/backup_$(date +%Y-%m-%d)"
EXCLUDE_FILE="$BACKUP_MOUNT_POINT/exclude_list.txt"
LOG_FILE="$BACKUP_MOUNT_POINT/backup.log"
MAX_LOG_SIZE=1048576

# Function to log messages
log_message() {
    local MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE" > /dev/null
}

# Log rotation
if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE") -ge $MAX_LOG_SIZE ]]; then
    mv "$LOG_FILE" "$LOG_FILE.old"
    log_message "Rotated $LOG_FILE to $LOG_FILE.old"
fi

# Ensure rsync is installed
if ! command -v rsync &> /dev/null; then
    log_message "rsync is not installed. Please install it and try again."
    exit 1
fi

# Check if the USB is mounted and writable
if [[ ! -d "$BACKUP_MOUNT_POINT" || ! -w "$BACKUP_MOUNT_POINT" ]]; then
    log_message "The backup USB is not mounted or writable at $BACKUP_MOUNT_POINT. Please check and try again."
    exit 1
fi

# Build the exclude options
EXCLUDE_OPTS=()
if [[ -f "$EXCLUDE_FILE" ]]; then
    while IFS= read -r EXCLUDE; do
        EXCLUDE_OPTS+=("--exclude=$EXCLUDE")
    done < "$EXCLUDE_FILE"
else
    log_message "Exclude file $EXCLUDE_FILE not found. Using default exclusions."
    EXCLUDE_OPTS=("--exclude=/dev" "--exclude=/proc" "--exclude=/sys" "--exclude=/tmp" "--exclude=/run" "--exclude=/mnt" "--exclude=/media" "--exclude=/lost+found" "--exclude=/var/tmp/systemd-private-*")
fi

# Perform a dry run if requested
if [[ "$1" == "--dry-run" ]]; then
    log_message "Performing a dry run of the backup..."
    rsync -aAXvn --delete "${EXCLUDE_OPTS[@]}" "$SOURCE" "$BACKUP_DIR"
    exit 0
fi

# Create the backup directory
if ! mkdir -p "$BACKUP_DIR"; then
    log_message "Failed to create backup directory at $BACKUP_DIR. Exiting."
    exit 1
fi

# Perform the backup
rsync -aAXv --delete "${EXCLUDE_OPTS[@]}" "$SOURCE" "$BACKUP_DIR" 2>> "$BACKUP_MOUNT_POINT/backup_error.log"
if [[ $? -eq 0 ]]; then
    log_message "Backup completed successfully."
else
    log_message "Backup encountered errors. Check backup_error.log for details."
fi
