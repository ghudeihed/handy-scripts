#!/bin/bash

LOG_FILE="gpu_setup.log"
NVIDIA_DRIVER_VERSION="535"
CUDA_VERSION="12.0"
CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64"
VENV_PATH="$HOME/ml_venv"
MAX_LOG_SIZE=1048576

log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a $LOG_FILE
}

validate_command() {
    if [ $? -ne 0 ]; then
        log_message "ERROR: $1 failed. Check $LOG_FILE for details. Exiting."
        exit 1
    else
        log_message "SUCCESS: $1 completed successfully."
    fi
}

retry_command() {
    local n=1
    local max=3
    local delay=5
    while true; do
        "$@" && break || {
            if [[ $n -lt $max ]]; then
                ((n++))
                delay=$((delay * 2))
                log_message "Attempt $n/$max failed for command: $@. Retrying in $delay seconds..."
                sleep $delay
            else
                log_message "ERROR: Command '$@' failed after $n attempts. Exiting."
                exit 1
            fi
        }
    done
}

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        log_message "ERROR: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

rotate_log() {
    if [[ -f $LOG_FILE && $(stat -c%s "$LOG_FILE") -ge $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        log_message "Rotated $LOG_FILE to ${LOG_FILE}.old"
    fi
}

cleanup() {
    log_message "Starting cleanup process."
    sudo apt-get remove --purge '^nvidia-.*' || true
    sudo apt-get autoremove -y && sudo apt-get autoclean
    validate_command "Cleanup completed"
}

pre_reboot_stage() {
    cleanup
    sudo apt update && sudo apt upgrade -y
    validate_command "System update and upgrade"
    sudo apt install -y nvidia-driver-$NVIDIA_DRIVER_VERSION
    validate_command "NVIDIA driver installation"
    log_message "Rebooting..."
    sudo reboot now
}

post_reboot_stage() {
    log_message "Installing CUDA Toolkit..."
    retry_command wget $CUDA_REPO_URL/cuda-ubuntu2004.pin
    validate_command "CUDA repository pin download"
    sudo apt update && sudo apt install -y cuda
    validate_command "CUDA installation"
    log_message "Setup complete!"
}
