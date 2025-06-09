#!/bin/bash

echo "Starting Wine Staging installation for Linux Mint 22.x (Ubuntu 24.04 Noble base)..."

# Step 1: Enable 32-bit architecture (multiarch)
echo "1. Enabling 32-bit architecture..."
sudo dpkg --add-architecture i386 || { echo "Failed to add i386 architecture. Exiting."; exit 1; }

# Step 2: Create keyrings directory and download/add the WineHQ repository key
echo "2. Adding WineHQ repository key..."
sudo mkdir -pm755 /etc/apt/keyrings || { echo "Failed to create /etc/apt/keyrings. Exiting."; exit 1; }
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key || { echo "Failed to download WineHQ key. Exiting."; exit 1; }

# Step 3: Add the WineHQ repository for Ubuntu 24.04 (Noble)
echo "3. Adding WineHQ repository for Noble (Ubuntu 24.04 base)..."
# Using -NP to prevent overwriting if file exists and -P to specify directory
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources || { echo "Failed to add WineHQ repository. Exiting."; exit 1; }

# Step 4: Update package lists
echo "4. Updating package lists..."
sudo apt update || { echo "Failed to update apt. Exiting."; exit 1; }

# Step 5: Install the Wine Staging branch
echo "5. Installing Wine Staging branch..."
sudo apt install --install-recommends winehq-staging || { echo "Failed to install winehq-staging. Exiting."; exit 1; }

echo "Wine Staging installation complete!"
echo "You can now run 'winecfg' in your terminal to set up Wine."
echo "If you encounter issues, please refer to the WineHQ wiki: https://gitlab.winehq.org/wine/wine/-/wikis/Debian-Ubuntu"

