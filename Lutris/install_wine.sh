#!/bin/bash

echo "Starting Wine Staging installation for Linux Mint 22.x (Ubuntu 24.04 Noble base)..."
echo "This script will attempt to automatically confirm all system package installation prompts."
echo "It will also install Wine-GE-Proton8-26 for Lutris."

# --- Section 1: System-wide Wine Staging Installation ---

echo -e "\n--- Part 1: Installing System-wide Wine Staging ---"

# Step 1: Enable 32-bit architecture (multiarch)
echo "1. Enabling 32-bit architecture..."
sudo dpkg --add-architecture i386 || { echo "ERROR: Failed to add i386 architecture. Please check your permissions or system configuration."; exit 1; }

# Step 2: Create keyrings directory and download/add the WineHQ repository key
echo "2. Adding WineHQ repository key..."
sudo mkdir -pm755 /etc/apt/keyrings || { echo "ERROR: Failed to create /etc/apt/keyrings directory. Check permissions."; exit 1; }
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key || { echo "ERROR: Failed to download WineHQ key. Check internet connection or URL."; exit 1; }

# Step 3: Add the WineHQ repository for Ubuntu 24.04 (Noble)
echo "3. Adding WineHQ repository for Noble (Ubuntu 24.04 base)..."
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources || { echo "ERROR: Failed to add WineHQ repository. Check internet connection or URL."; exit 1; }

# Step 4: Update package lists
echo "4. Updating package lists..."
sudo DEBIAN_FRONTEND=noninteractive apt update -y || { echo "ERROR: Failed to update package lists. Check internet connection or repository settings."; exit 1; }

# Step 5: Install the Wine Staging branch
echo "5. Installing Wine Staging branch..."
yes | sudo DEBIAN_FRONTEND=noninteractive apt install --install-recommends winehq-staging -y || { echo "ERROR: Failed to install winehq-staging. Check error messages above for details."; exit 1; }

echo "System-wide Wine Staging installation complete!"

# --- Section 2: Lutris Wine-GE-Proton8-26 Installation ---

echo -e "\n--- Part 2: Installing Wine-GE-Proton8-26 for Lutris ---"

# Define variables for Wine-GE
WINE_GE_VERSION="wine-lutris-GE-Proton8-26-x86_64"
WINE_GE_ARCHIVE="${WINE_GE_VERSION}.tar.xz"
WINE_GE_DOWNLOAD_URL="https://github.com/GloriousEggroll/wine-ge-custom/releases/download/GE-Proton8-26/${WINE_GE_ARCHIVE}"
LUTRIS_WINE_DIR="${HOME}/.local/share/lutris/runners/wine"
WINE_GE_INSTALL_PATH="${LUTRIS_WINE_DIR}/${WINE_GE_VERSION}"
TEMP_DIR="/tmp/wine_ge_install" # Temporary directory for download and extraction

# Check if Lutris is installed (optional but good practice)
if ! command -v lutris &> /dev/null
then
    echo "WARNING: Lutris is not found in your PATH. Please ensure Lutris is installed for this Wine-GE version to be useful."
    echo "You can install Lutris via: sudo apt install lutris"
fi

# Create Lutris Wine runners directory if it doesn't exist
echo "1. Creating Lutris Wine runners directory: ${LUTRIS_WINE_DIR}..."
mkdir -p "${LUTRIS_WINE_DIR}" || { echo "ERROR: Failed to create Lutris Wine directory. Check permissions."; exit 1; }

# Create temporary directory for download and extraction
echo "2. Creating temporary directory: ${TEMP_DIR}..."
mkdir -p "${TEMP_DIR}" || { echo "ERROR: Failed to create temporary directory. Check permissions."; exit 1; }

# Check if Wine-GE version is already installed
if [ -d "${WINE_GE_INSTALL_PATH}" ]; then
    echo "Wine-GE-Proton8-26 is already installed at ${WINE_GE_INSTALL_PATH}. Skipping download and extraction."
else
    # Download the Wine-GE archive
    echo "3. Downloading ${WINE_GE_ARCHIVE} from ${WINE_GE_DOWNLOAD_URL}..."
    wget -c "${WINE_GE_DOWNLOAD_URL}" -P "${TEMP_DIR}" || { echo "ERROR: Failed to download Wine-GE archive. Check internet connection or URL."; rm -rf "${TEMP_DIR}"; exit 1; }

    # Extract the archive
    echo "4. Extracting ${WINE_GE_ARCHIVE} to ${LUTRIS_WINE_DIR}..."
    # The 'J' option for xz, 'x' for extract, 'f' for file, 'C' to change directory before extracting.
    # We extract directly to LUTRIS_WINE_DIR assuming the archive contains a top-level directory matching WINE_GE_VERSION.
    tar -xf "${TEMP_DIR}/${WINE_GE_ARCHIVE}" -C "${LUTRIS_WINE_DIR}" || { echo "ERROR: Failed to extract Wine-GE archive. Check archive integrity or disk space."; rm -rf "${TEMP_DIR}"; exit 1; }
fi

# Clean up temporary files
echo "5. Cleaning up temporary files..."
rm -rf "${TEMP_DIR}" || { echo "WARNING: Failed to remove temporary directory ${TEMP_DIR}. Please remove it manually."; }

echo "Wine-GE-Proton8-26 installation for Lutris complete!"
echo "You may need to restart Lutris for the new Wine-GE version to appear in its settings."

# --- Final Notes ---
echo -e "\n--- Installation Summary ---"
echo "Both Wine Staging (system-wide) and Wine-GE-Proton8-26 (for Lutris) have been processed."
echo "To use Wine-GE-Proton8-26 in Lutris, go to a game's 'Configure' > 'Runner options' and select it from the 'Wine version' dropdown."
echo "Please note that Wine-GE-Custom builds (like 8-26) are somewhat older, as GloriousEggroll has shifted focus to GE-Proton builds, which are more commonly used with Steam but also work with Lutris."
echo "For the latest Wine builds for gaming, consider exploring newer GE-Proton versions directly within Lutris's Wine version manager or using a tool like ProtonUp-Qt."
echo "If you encounter any issues, please refer to the WineHQ wiki: https://gitlab.winehq.org/wine/wine/-/wikis/Debian-Ubuntu"
echo "And the GloriousEggroll GitHub releases for Wine-GE/Proton-GE: https://github.com/GloriousEggroll/wine-ge-custom/releases"

