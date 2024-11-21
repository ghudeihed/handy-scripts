#!/bin/bash

# Log file
LOG_FILE="/var/log/system_setup.log"
LOG_MAX_SIZE=1048576  # 1MB

exec > >(tee -a "$LOG_FILE") 2>&1
exec 2>&1

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message"
}

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    log_message "This script must be run as root. Please use sudo."
    exit 1
fi

# Check dependencies
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        log_message "ERROR: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

for cmd in sudo apt flatpak sed; do
    check_dependency "$cmd"
done

# Rotate log if needed
if [[ -f $LOG_FILE && $(stat -c%s "$LOG_FILE") -ge $LOG_MAX_SIZE ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.old"
    log_message "Rotated $LOG_FILE to ${LOG_FILE}.old"
fi

# Install required packages
install_packages() {
    log_message "Installing required packages..."
    sudo apt update -y

    PACKAGES=(
        "apcupsd"
        "bridge-utils"
        "cmake"
        "containerd"
        "docker.io"
        "python3-dev"
        "python3-pip"
        "runc"
        "linux-headers-generic"
        "testdisk"
        "python-is-python3"
        "python3-poetry"
        "libcanberra-gtk-module"
        "libcanberra-gtk3-module"
        "kexec-tools"
        "smartmontools"
        "libcudnn9-dev"
        "libcudnn9"
        "libopenmpi-dev"
        "openmpi-bin"
        "blueman"
        "linux-generic"
        "gnome-tweaks"
        "libnvidia-container-tool"
        "libnvidia-container1"
        "cryptsetup"
        "flatpak"
        "gnome-software-plugin-flatpak"
    )

    for package in "${PACKAGES[@]}"; do
        log_message "Installing $package..."
        if ! sudo apt install -y "$package"; then
            log_message "ERROR: Failed to install $package. Continuing..."
        fi
    done
    log_message "Package installation completed."
}

# Set up Flatpak
setup_flatpak() {
    log_message "Setting up Flatpak..."
    if ! flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
        log_message "ERROR: Failed to add Flatpak repository."
        return 1
    fi

    if ! flatpak install -y flathub org.videolan.VLC; then
        log_message "ERROR: Failed to install VLC via Flatpak."
        return 1
    fi

    log_message "Flatpak and VLC installed successfully."
}

# Configure USB autosuspend
configure_usb_autosuspend() {
    log_message "Configuring USB autosuspend..."
    echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend > /dev/null
    log_message "Temporarily disabled USB autosuspend."

    GRUB_CONFIG="/etc/default/grub"
    if grep -q "usbcore.autosuspend" "$GRUB_CONFIG"; then
        log_message "USB autosuspend already configured in GRUB."
    else
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&usbcore.autosuspend=-1 /' "$GRUB_CONFIG"
        sudo update-grub
        log_message "Updated GRUB to disable USB autosuspend persistently."
    fi
}

# Main execution
log_message "Starting system setup..."
install_packages
setup_flatpak
configure_usb_autosuspend
log_message "System setup completed. Please reboot your system for all changes to take effect."

read -p "Reboot is required. Reboot now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    sudo reboot
else
    log_message "Reboot skipped. Please reboot manually."
fi
