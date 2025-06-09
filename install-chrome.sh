#!/bin/bash

# This script automates the installation of Google Chrome Stable on Linux Mint.
# It downloads the official .deb package and installs it using apt.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Google Chrome installation script for Linux Mint..."
echo "This script will require sudo privileges for package installation."

# --- Step 1: Define Chrome Stable .deb download URL ---
# You can get the latest URL from the official Google Chrome download page
CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
DEB_FILE_NAME="google-chrome-stable_current_amd64.deb"

# --- Step 2: Remove any existing Chrome installations (optional but good practice) ---
echo ""
echo "--- Step 2: Attempting to remove any existing Google Chrome installations ---"
# This helps prevent conflicts if a partial or older installation exists.
# We use `|| true` to prevent the script from exiting if the package isn't found.
sudo apt remove --purge google-chrome-stable google-chrome-beta google-chrome-unstable -y || true
echo "Attempted to remove existing Chrome installations."

# --- Step 3: Download the Google Chrome .deb package ---
echo ""
echo "--- Step 3: Downloading Google Chrome .deb package ---"
echo "Downloading from: $CHROME_DEB_URL"
wget -O "$DEB_FILE_NAME" "$CHROME_DEB_URL"
echo "Download complete: $DEB_FILE_NAME"

# --- Step 4: Install the Google Chrome .deb package ---
echo ""
echo "--- Step 4: Installing Google Chrome ---"
# `sudo apt install ./<package_name>.deb` handles dependencies automatically.
sudo apt install "./$DEB_FILE_NAME" -y
echo "Google Chrome installation complete."

# --- Step 5: Clean up the downloaded .deb file ---
echo ""
echo "--- Step 5: Cleaning up downloaded .deb file ---"
rm "$DEB_FILE_NAME"
echo "Removed $DEB_FILE_NAME"

# --- Step 6: Verification ---
echo ""
echo "--- Step 6: Verification ---"
echo "To verify the installation, you can try to launch Google Chrome from your applications menu."
echo "Alternatively, you can run the following command in your terminal:"
echo "google-chrome --version"
echo ""
echo "If the version number is displayed, Google Chrome is successfully installed."

echo ""
echo "Google Chrome installation script finished."
