#!/bin/bash

# This script automates the installation and configuration of CAC reader support on Linux Mint.
# It installs necessary packages, configures browser integration, and restarts relevant services.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting CAC reader setup script for Linux Mint..."
echo "This script will require sudo privileges for package installation and system configuration."

# --- Step 1: Update and Upgrade System Packages ---
echo ""
echo "--- Step 1: Updating and upgrading system packages ---"
sudo apt update -y
sudo apt upgrade -y
echo "System packages updated and upgraded."

# --- Step 2: Install Core CAC and Smart Card Packages ---
echo ""
echo "--- Step 2: Installing core CAC and smart card packages ---"
# pcscd: PC/SC Smart Card Daemon - essential for smart card communication
# pcsc-tools: Utilities for PC/SC (e.g., pcsc_scan)
# libccid: Common Interface Device driver for PC/SC smart card readers
# opensc: Smart card utilities and drivers, including PKCS#11 module for various cards
# libpam-pkcs11: PAM module for PKCS#11 (for authentication via smart card)
# coolkey: Smart card PKCS#11 module, often used with DoD CAC cards
# libcackey: Another smart card PKCS#11 module specific for CAC cards
# libnss3-tools: Network Security Services tools, required for browser integration
sudo apt install -y pcscd pcsc-tools libccid opensc libpam-pkcs11 coolkey libcackey libnss3-tools

echo "Core CAC and smart card packages installed."

# --- Step 3: Configure Browser Integration (Firefox/Chrome) ---
# This step adds the OpenSC and Coolkey PKCS#11 modules to your browser's NSS database.
# This allows the browser to use your CAC card for secure website authentication.

# Firefox
echo ""
echo "--- Step 3: Configuring Firefox for CAC reader integration ---"
# Check if NSS database exists for Firefox profile, create if not
FIREFOX_PROFILE_DIR=$(find ~/.mozilla/firefox/ -maxdepth 1 -type d -name "*.default-release" -print -quit)
if [ -z "$FIREFOX_PROFILE_DIR" ]; then
    echo "Could not find a default Firefox profile directory. Please ensure Firefox has been opened at least once."
else
    # Attempt to add opensc-pkcs11.so
    modutil -dbdir "$FIREFOX_PROFILE_DIR" -add "OpenSC PKCS#11 Module" -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so -force || \
    echo "Warning: Could not add OpenSC PKCS#11 module for Firefox. It might already be added or the path is incorrect."
    
    # Attempt to add coolkey.so
    modutil -dbdir "$FIREFOX_PROFILE_DIR" -add "CoolKey PKCS#11 Module" -libfile /usr/lib/x86_64-linux-gnu/pkcs11/coolkey.so -force || \
    echo "Warning: Could not add CoolKey PKCS#11 module for Firefox. It might already be added or the path is incorrect."
    
    echo "Firefox configuration commands executed. You may need to restart Firefox."
fi


# Chrome/Chromium
echo ""
echo "--- Step 3b: Configuring Chrome/Chromium for CAC reader integration (system-wide) ---"
# Chromium/Chrome often uses the system-wide NSS database or can load modules directly.
# The `modutil` command below adds the modules to the default system-wide NSS database,
# which many Chromium-based browsers can utilize.
NSS_DB_DIR="${HOME}/.pki/nssdb"

# Create NSS database if it doesn't exist
if [ ! -d "$NSS_DB_DIR" ]; then
    echo "Creating NSS database directory: $NSS_DB_DIR"
    mkdir -p "$NSS_DB_DIR"
    certutil -N -d "sql:$NSS_DB_DIR" --empty-password || echo "Failed to create NSS database for Chrome/Chromium."
fi

if [ -d "$NSS_DB_DIR" ]; then
    # Attempt to add opensc-pkcs11.so
    modutil -dbdir "sql:$NSS_DB_DIR" -add "OpenSC PKCS#11 Module" -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so -force || \
    echo "Warning: Could not add OpenSC PKCS#11 module for Chrome/Chromium. It might already be added or the path is incorrect."

    # Attempt to add coolkey.so
    modutil -dbdir "sql:$NSS_DB_DIR" -add "CoolKey PKCS#11 Module" -libfile /usr/lib/x86_64-linux-gnu/pkcs11/coolkey.so -force || \
    echo "Warning: Could not add CoolKey PKCS#11 module for Chrome/Chromium. It might already be added or the path is incorrect."
    
    echo "Chrome/Chromium configuration commands executed. You may need to restart your browser."
fi

# --- Step 4: Restart PC/SC Daemon Service ---
echo ""
echo "--- Step 4: Restarting PC/SC Daemon service ---"
sudo systemctl restart pcscd
echo "PC/SC Daemon service restarted."

# --- Step 5: Verification and Next Steps ---
echo ""
echo "--- Step 5: Verification and Next Steps ---"
echo "Setup script completed. Please perform the following checks:"
echo ""
echo "1. Verify pcscd service status:"
echo "   systemctl status pcscd"
echo "   It should show 'active (running)'."
echo ""
echo "2. Check your CAC reader with pcsc_scan (with CAC card inserted):"
echo "   pcsc_scan"
echo "   You should see output indicating your reader and card are detected."
echo "   Press Ctrl+C to exit pcsc_scan."
echo ""
echo "3. Restart your web browser (Firefox/Chrome) and try accessing a CAC-enabled website."
echo "   You might need to import certificates or trust specific CAs depending on your organization's requirements."
echo "   For Firefox, go to Edit -> Preferences -> Privacy & Security -> Certificates -> Security Devices to see if OpenSC and CoolKey are listed."
echo ""
echo "If you encounter issues, consider the following:"
echo " - Ensure your CAC reader is properly connected."
echo " - Double-check the physical CAC card insertion."
echo " - Consult specific guides for your organization's CAC setup (e.g., DoD)."
echo " - Search for error messages online if problems persist."

echo ""
echo "Setup script finished. Good luck!"
