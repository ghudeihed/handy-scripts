#!/bin/bash

# Path to your extensions.json file
EXTENSIONS_JSON_PATH="../configs/extensions.json"
LOG_FILE="extensions_install.log"

# Redirect output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to check if a command is available
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

# Ensure required dependencies are installed
check_dependency jq
check_dependency code

# Check if the extensions.json file exists
if [ ! -f "$EXTENSIONS_JSON_PATH" ]; then
    echo "ERROR: File $EXTENSIONS_JSON_PATH not found!"
    exit 1
fi

# Validate JSON format
if ! jq empty "$EXTENSIONS_JSON_PATH" &> /dev/null; then
    echo "ERROR: Invalid JSON format in $EXTENSIONS_JSON_PATH."
    exit 1
fi

# Extract the "id" of each extension from the extensions.json file
extensions=$(jq -r '.[].identifier.id' "$EXTENSIONS_JSON_PATH")

# Handle empty or missing extensions
if [[ -z "$extensions" ]]; then
    echo "No extensions found in $EXTENSIONS_JSON_PATH."
    exit 0
fi

# Provide dry-run option
if [[ "$1" == "--dry-run" ]]; then
    echo "Dry run mode: The following extensions would be installed:"
    echo "$extensions"
    exit 0
fi

# Install extensions
echo "Installing extensions from $EXTENSIONS_JSON_PATH..."
for extension in $extensions; do
    echo "Installing $extension..."
    if code --install-extension "$extension"; then
        echo "SUCCESS: $extension installed."
    else
        echo "ERROR: Failed to install $extension."
    fi
done

echo "All extensions processed. Check $LOG_FILE for details."
