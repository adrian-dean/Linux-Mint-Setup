#!/bin/bash

echo "Starting Flatseal installation on Linux Mint..."

# Step 1: Check if Flatpak is installed. If not, install it.
if ! command -v flatpak &> /dev/null
then
    echo "Flatpak is not installed. Installing Flatpak..."
    sudo apt update
    sudo apt install flatpak -y
    echo "Flatpak installed successfully."
else
    echo "Flatpak is already installed."
fi

# Step 2: Add the Flathub repository. This is where Flatseal is hosted.
echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "Flathub repository added."

# Step 3: Install Flatseal from Flathub.
echo "Installing Flatseal..."
flatpak install flathub com.github.tchx84.Flatseal -y
echo "Flatseal installed successfully!"

echo "Installation complete. You can now find Flatseal in your applications menu."
echo "You may need to restart your session or log out and log back in for Flatseal to appear."
