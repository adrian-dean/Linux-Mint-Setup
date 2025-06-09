#!/bin/bash

# Function to install Lutris
install_lutris() {
    echo "Starting Lutris installation..."

    # Create a temporary directory for downloads
    INSTALL_DIR=$(mktemp -d)
    cd "$INSTALL_DIR" || { echo "Failed to change to temporary directory. Exiting."; exit 1; }

    # Get the latest Lutris .deb URL from GitHub releases
    LATEST_RELEASE_URL=$(wget -qO- https://api.github.com/repos/lutris/lutris/releases/latest | grep "browser_download_url.*\.deb" | cut -d : -f 2,3 | tr -d \" | wget -i -)

    if [ -z "$LATEST_RELEASE_URL" ]; then
        echo "Could not find the latest Lutris .deb release URL. Exiting."
        exit 1
    fi

    echo "Downloading the latest Lutris .deb from: $LATEST_RELEASE_URL"
    wget "$LATEST_RELEASE_URL" || { echo "Failed to download Lutris .deb. Exiting."; exit 1; }

    DEB_FILE=$(basename "$LATEST_RELEASE_URL")

    # Install the .deb file
    echo "Installing $DEB_FILE..."
    sudo dpkg -i "$DEB_FILE"

    # Resolve any broken dependencies
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
