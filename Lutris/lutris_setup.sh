#!/bin/bash

# Function to install Lutris
install_lutris() {
    echo "Starting Lutris installation..."

    # Create a temporary directory for downloads
    INSTALL_DIR=$(mktemp -d)
    cd "$INSTALL_DIR" || { echo "Failed to change to temporary directory. Exiting."; exit 1; }

    # Get the latest Lutris .deb URL from GitHub releases
    # This uses 'jq' to parse the JSON output from the GitHub API, which is more reliable
    # than string manipulation with grep/cut for URLs.
    # If 'jq' is not installed, the script will prompt to install it.
    if ! command -v jq &> /dev/null
    then
        echo "'jq' is not installed. It's needed to parse the GitHub API response."
        echo "Installing 'jq'..."
        sudo apt update
        sudo apt install -y jq || { echo "Failed to install 'jq'. Exiting."; exit 1; }
    fi

    LATEST_RELEASE_URL=$(wget -qO- https://api.github.com/repos/lutris/lutris/releases/latest | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url')

    if [ -z "$LATEST_RELEASE_URL" ]; then
        echo "Error: Could not find the latest Lutris .deb release URL. Please check the GitHub releases page manually: https://github.com/lutris/lutris/releases"
        exit 1
    fi

    echo "Downloading the latest Lutris .deb from: $LATEST_RELEASE_URL"
    wget "$LATEST_RELEASE_URL" || { echo "Failed to download Lutris .deb. Exiting."; exit 1; }

    DEB_FILE=$(basename "$LATEST_RELEASE_URL")

    # Install the .deb file
    echo "Installing $DEB_FILE..."
    sudo dpkg -i "$DEB_FILE"

    # Resolve any broken dependencies
    echo "Attempting to resolve any broken dependencies..."
    sudo apt install -f -y

    echo "Lutris installation complete."

    # Clean up the temporary directory
    cd - > /dev/null # Go back to the previous directory
    rm -rf "$INSTALL_DIR"
    echo "Cleaned up temporary files."
}

# Run the installation function
install_lutris

echo "Script finished."
