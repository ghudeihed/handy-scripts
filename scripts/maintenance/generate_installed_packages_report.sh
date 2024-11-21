#!/bin/bash

# Output file
output_file="reports/installed_packages_report.txt"

# Ensure the script can write to the output file
if ! touch "$output_file" &> /dev/null; then
    echo "Cannot write to $output_file. Check permissions or path." >&2
    exit 1
fi

# Redirect all output to log file
exec > >(tee -a "$output_file") 2>&1

# Dependencies
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 is not installed. Please install it and try again."
        exit 1
    fi
}

# Validate required commands
for cmd in apt dpkg snap flatpak pip; do
    check_dependency "$cmd"
done

# Rotate log if size exceeds 1MB
if [[ -f "$output_file" && $(stat -c%s "$output_file") -ge 1048576 ]]; then
    mv "$output_file" "${output_file}.old"
    echo "Rotated $output_file to ${output_file}.old"
fi

# Helper to print headers
print_header() {
    local header="$1"
    echo "======================================================="
    echo "$header"
    echo "======================================================="
    echo ""
}

# Header
print_header "Comprehensive Installed Applications and Packages Report"

# APT installed packages
print_header "APT Packages"
apt list --installed

# DPKG installed packages
print_header "DPKG Packages"
dpkg --list

# Snap installed applications
print_header "Snap Packages"
snap list

# Flatpak installed applications
if command -v flatpak &> /dev/null; then
    print_header "Flatpak Applications"
    flatpak list
else
    echo "Flatpak not installed."
fi

# Python packages installed with pip
if command -v pip &> /dev/null; then
    print_header "Python Packages (via pip)"
    pip list
else
    echo "Pip not installed."
fi

# Manually installed applications in /usr/local/ and /opt/
print_header "Manually Installed Applications"
ls /usr/local/
echo ""
ls /opt/

# AppImage search
print_header "AppImage Applications"
find ~/Applications /opt /usr/local -name "*.AppImage" 2>/dev/null

# Configuration files search
print_header "Configuration Files for Installed Packages"

# APT/DPKG config files
print_header "APT/DPKG Configuration Files"
dpkg --list | awk '{print $2}' | while read pkg; do
    config_file=$(dpkg -L "$pkg" 2>/dev/null | grep "/etc/")
    if [ -n "$config_file" ]; then
        echo "$pkg:"
        echo "$config_file"
    else
        echo "$pkg: No configuration files found."
    fi
done

# Snap config files
print_header "Snap Configuration Files"
snap list | awk '{if (NR!=1) print $1}' | while read snap_pkg; do
    config_file=$(find /var/snap/$snap_pkg -type f -name "*.conf" 2>/dev/null)
    if [ -n "$config_file" ]; then
        echo "$snap_pkg:"
        echo "$config_file"
    else
        echo "$snap_pkg: No configuration files found."
    fi
done

# Pip package config files
if command -v pip &> /dev/null; then
    print_header "Pip Configuration Files"
    pip list --format=freeze | cut -d "=" -f 1 | while read pip_pkg; do
        config_file=$(find /usr/local/lib/python*/dist-packages/$pip_pkg -type f -name "*.conf" 2>/dev/null)
        if [ -n "$config_file" ]; then
            echo "$pip_pkg:"
            echo "$config_file"
        else
            echo "$pip_pkg: No configuration files found."
        fi
    done
fi

# Final message
print_header "Report completed. Check $output_file for details."
