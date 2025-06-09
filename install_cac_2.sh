#!/bin/bash

# --- Function to display messages ---
log_message() {
    echo "--- $1 ---"
}

# --- Function to check for root privileges ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run with sudo or as root."
        exit 1
    fi
}

# --- Main script starts here ---
check_root

log_message "Starting CAC installation and configuration..."

# --- Detect Linux Distribution ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION_ID=$VERSION_ID
else
    echo "Cannot determine Linux distribution. Exiting."
    exit 1
fi

log_message "Detected distribution: $DISTRO (Version: $VERSION_ID)"

# --- Install Packages ---
log_message "Installing necessary packages..."

case "$DISTRO" in
    ubuntu|debian|linuxmint|pop)
        sudo apt update
        sudo apt install -y pcscd pcsc-tools libacr38u libacr38u-dev libccid opensc opensc-pkcs11 coolkey libnss3-tools
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install packages using apt. Please check your internet connection and package names."
            exit 1
        fi
        ;;
    fedora|centos|rhel)
        sudo dnf install -y pcsc-lite pcsc-tools ccid opensc opensc-pkcs11 coolkey nss-tools
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install packages using dnf. Please check your internet connection and package names."
            exit 1
        fi
        ;;
    arch|manjaro)
        sudo pacman -Sy --noconfirm pcscd pcsc-tools ccid opensc coolkey nss
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install packages using pacman. Please check your internet connection and package names."
            exit 1
        fi
        ;;
    *)
        echo "Unsupported distribution: $DISTRO. Please install packages manually."
        exit 1
        ;;
esac

log_message "Packages installed successfully."

# --- Start and Enable pcscd service ---
log_message "Starting and enabling pcscd service..."
sudo systemctl start pcscd
sudo systemctl enable pcscd
if [ $? -ne 0 ]; then
    echo "Warning: Could not start or enable pcscd service. Please check manually."
else
    log_message "pcscd service is running and enabled."
fi

# --- Test Smart Card Reader ---
log_message "Testing smart card reader (insert your CAC now if it's not in)..."
echo "Running 'pcsc_scan' for 10 seconds. Press Ctrl+C to stop early."
timeout 10 pcsc_scan
echo "" # Newline for better readability

log_message "Smart card reader test complete. If you saw 'Card present: Yes', your reader is detected."

# --- Provide Web Browser Configuration Instructions ---
log_message "--- Next Steps: Web Browser Configuration & DoD Certificates ---"
echo "The core components for CAC support are now installed."
echo "However, you MUST perform these steps manually:"
echo ""
echo "1.  **Configure Web Browsers (Firefox/Chrome):**"
echo "    * **Mozilla Firefox:**"
echo "        1.  Open Firefox, go to 'Settings' (hamburger menu) -> 'Privacy & Security'."
echo "        2.  Scroll to 'Certificates' and click 'Security Devices...'."
echo "        3.  Click 'Load', give it a name (e.g., 'OpenSC'), and for 'Module filename', use one of these common paths:"
echo "            -   /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so (most common for 64-bit Debian/Ubuntu)"
echo "            -   /usr/lib/opensc-pkcs11.so"
echo "            -   /usr/lib64/opensc-pkcs11.so (common for 64-bit Fedora/Red Hat)"
echo "        4.  (Optional) If you installed CoolKey, try /usr/lib/libcoolkeypk11.so"
echo "        5.  Click 'OK'."
echo "    * **Google Chrome/Chromium:**"
echo "        Chrome often works out-of-the-box with OpenSC, but if not, you can try this command in your terminal:"
echo "        modutil -add \"OpenSC\" -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so -dbdir sql:\$HOME/.pki/nssdb"
echo "        (Adjust the -libfile path if necessary, use one of the paths mentioned for Firefox.)"
echo ""
echo "2.  **Install DoD Certificates:**"
echo "    * You need to install the DoD Root Certificates for many government websites to trust your CAC."
echo "    * **Download:** Obtain the official DoD Root Certificates from a trusted source (e.g., searching for 'DoD Root Certificates' on a government website)."
echo "    * **Import into Firefox:** In Firefox, go to 'Settings' -> 'Privacy & Security' -> 'View Certificates...' -> 'Authorities' tab -> 'Import...'. Import each certificate file and choose 'Trust this CA to identify websites'."
echo "    * **System-wide (for Chrome/system trust):**"
echo "        -   **Debian/Ubuntu:** Copy .crt/.pem files to /usr/local/share/ca-certificates/dod/ then run 'sudo update-ca-certificates'."
echo "        -   **Fedora/Red Hat:** Copy .crt/.pem files to /etc/pki/ca-trust/source/anchors/ then run 'sudo update-ca-trust extract'."
echo ""
log_message "CAC installation script finished. Please proceed with the manual browser and certificate steps."
