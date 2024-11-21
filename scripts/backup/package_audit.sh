#!/bin/bash

# Log file
LOG_FILE="package_check.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Lists of packages
must_have=(
    "apcupsd"
    "bridge-utils"
    "cmake"
    "containerd"
    "cuda-*"
    "docker.io"
    "python3-dev"
    "python3-pip"
    "runc"
    "linux-headers"
    "cudnn9-cuda-*"
    "nsight-compute"
    "testdisk"
)
good_to_have=(
    "clinfo"
    "gparted"
    "smartmontools"
    "default-jre"
    "default-jre-headless"
    "cmake-data"
    "cuda-documentation-12-6"
    "kexec-tools"
    "google-chrome-stable"
    "pigz"
)
not_needed=(
    "apcupsd-doc"
    "gds-tools-12-6"
    "gir1.2-javascriptcoregtk-*"
    "libatkmm-1.6-1v5"
    "libcairomm-1.0-1v5"
    "libcanberra-gtk-module"
    "libcanberra-gtk0"
    "libglibmm-2.4-1t64"
    "libgtkmm-3.0-1t64"
    "libice-dev"
    "libcurand-12-6"
    "libcurand-dev-12-6"
    "libexpat1-dev"
    "libfuse2t64"
    "libpangomm-1.4-1v5"
    "libjs-sphinxdoc"
    "libjs-underscore"
    "ubuntu-fan"
    "cuda-sanitizer-12-6"
    "cuda-profiler-api-12-6"
)

# Check if a command exists
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

# Ensure required dependencies are installed
for cmd in dpkg apt which; do
    check_dependency "$cmd"
done

# Check for installed packages
check_package() {
    package_name=$1
    if dpkg -l | grep -q "^ii  $package_name"; then
        echo "$package_name is installed."
    else
        echo "$package_name is NOT installed."
    fi
}

# Check for wildcard packages
check_wildcard_package() {
    wildcard=$1
    if dpkg -l | grep -q "^ii  $wildcard"; then
        echo "$wildcard* package(s) are installed."
    else
        echo "$wildcard* package(s) are NOT installed."
    fi
}

# Check for unnecessary packages
check_not_needed_package() {
    package_name=$1
    if dpkg -l | grep -q "^ii  $package_name"; then
        echo "WARNING: $package_name is installed but marked as not needed."
    fi
}

# Process must-have packages
echo "======================"
echo "Must-Have Packages"
echo "======================"
for package in "${must_have[@]}"; do
    if [[ "$package" == *"*" ]]; then
        check_wildcard_package "$package"
    else
        check_package "$package"
    fi
done

# Process not-needed packages
echo "======================"
echo "Not Needed Packages"
echo "======================"
for package in "${not_needed[@]}"; do
    check_not_needed_package "$package"
done
