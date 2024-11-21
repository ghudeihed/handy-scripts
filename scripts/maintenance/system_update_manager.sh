#!/bin/bash

# Script to update and upgrade all system parts with improvements

LOG_FILE="/var/log/system_update.log"
LOCK_FILE="/tmp/system_update.lock"

# Redirect output to log file
exec > >(tee -a $LOG_FILE) 2>&1

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo." >&2
    exit 1
fi

# Ensure only one instance of the script runs at a time
if [ -e "$LOCK_FILE" ]; then
    echo "Another instance of the script is running. Exiting."
    exit 1
fi

trap "rm -f $LOCK_FILE" EXIT

touch $LOCK_FILE

update_packages() {
    echo "Updating package list..."
    if sudo apt-get update -y; then
        echo "Package list updated successfully."
    else
        echo "Failed to update package list." >&2
        exit 1
    fi
}

upgrade_packages() {
    echo "Upgrading packages..."
    if sudo apt-get upgrade -y; then
        echo "Packages upgraded successfully."
    else
        echo "Failed to upgrade packages." >&2
        exit 1
    fi
}

dist_upgrade() {
    echo "Performing full distribution upgrade..."
    if sudo apt-get dist-upgrade -y; then
        echo "Full distribution upgrade completed successfully."
    else
        echo "Failed to perform full distribution upgrade." >&2
        exit 1
    fi
}

autoremove_packages() {
    echo "Removing unnecessary packages..."
    if sudo apt-get autoremove -y; then
        echo "Unnecessary packages removed successfully."
    else
        echo "Failed to remove unnecessary packages." >&2
        exit 1
    fi
}

cleanup_packages() {
    echo "Cleaning up..."
    if sudo apt-get autoclean -y; then
        echo "Cleanup completed successfully."
    else
        echo "Failed to clean up." >&2
        exit 1
    fi
}

send_notification() {
    if command -v mail &> /dev/null; then
        echo "System update completed successfully" | mail -s "Update Notification" user@example.com
    else
        echo "Mail utility not found. Skipping email notification."
    fi
}

# Execute update functions
update_packages
upgrade_packages
dist_upgrade
autoremove_packages
cleanup_packages

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "Reboot is required. Rebooting now..."
    sudo reboot
fi

# Send email notification
send_notification

echo "Update and upgrade complete!"
