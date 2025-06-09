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

log_message "Starting CAC installation and configuration for Linux Mint..."

# --- Install Packages ---
log_message "Updating package lists and installing necessary packages..."

# Removed libacr38u and libacr38u-dev as they may not be available or needed in newer distros
sudo apt update
sudo apt install -y pcscd pcsc-tools libccid opensc opensc-pkcs11 coolkey libnss3-tools

if [ $? -ne 0 ]; then
    echo "Error: Failed to install packages using apt. Please check your internet connection and package names."
    echo "It's possible some packages are still missing. You can try installing them manually if issues persist."
    exit 1
fi

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
# Ensure 'timeout' command is available (part of coreutils, usually present)
if ! command -v timeout &> /dev/null; then
    echo "Warning: 'timeout' command not found. Skipping timed pcsc_scan."
    echo "You can run 'pcsc_scan' manually and press Ctrl+C to exit."
    pcsc_scan
else
    timeout 10 pcsc_scan
fi
echo "" # Newline for better readability

log_message "Smart card reader test complete. If you saw 'Card present: Yes' in the output, your reader is detected."
echo "If not, please ensure your reader is connected and recognized by the system."

# --- Provide Web Browser Configuration Instructions ---
log_message "--- Next Steps: Web Browser Configuration & DoD Certificates ---"
echo "The core components for CAC support are now installed on your Linux Mint system."
echo "However, you MUST perform these steps manually to fully enable CAC usage:"
echo ""
echo "1.  **Configure Web Browsers (Firefox/Chrome/Chromium):**"
echo "    * **Mozilla Firefox:**"
echo "        1.  Open Firefox, go to 'Settings' (or the hamburger menu) -> 'Privacy & Security'."
echo "        2.  Scroll down to 'Certificates' and click 'Security Devices...'."
echo "        3.  Click 'Load', give it a name (e.g., 'OpenSC' or 'CAC Reader')."
echo "        4.  For 'Module filename', use the common path for 64-bit Debian/Ubuntu systems:"
echo "            /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so"
echo "            (If you also installed CoolKey and want to try it, its path might be /usr/lib/x86_64-linux-gnu/libcoolkeypk11.so or /usr/lib/libcoolkeypk11.so)"
echo "        5.  Click 'OK'."
echo "    * **Google Chrome/Chromium:**"
echo "        Chrome often works out-of-the-box with OpenSC. If it doesn't, you can try adding the module to its NSS database via the terminal:"
echo "        modutil -add \"OpenSC\" -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so -dbdir sql:\$HOME/.pki/nssdb"
echo "        (The path for '-libfile' is the same as for Firefox. The '\$HOME' ensures it uses your user's NSS database.)"
echo ""
echo "2.  **Install DoD Certificates:**"
echo "    * You need to install the DoD Root Certificates for many government websites to trust your CAC."
echo "    * **Download:** Obtain the official DoD Root Certificates from a trusted source (e.g., search for 'DoD Root Certificates' on a government website you need to access). They often come in a .zip file."
echo "    * **Import into Firefox:** In Firefox, go to 'Settings' -> 'Privacy & Security' -> 'View Certificates...' -> 'Authorities' tab -> 'Import...'. Import each certificate file (typically .der or .p7b) and select 'Trust this CA to identify websites'."
echo "    * **Import System-wide (Recommended for Chrome and overall system trust):**"
echo "        1.  Extract the downloaded DoD certificates. You'll likely find .cer or .der files. Convert them to .crt if necessary (e.g., 'openssl x509 -inform der -in certificate.der -out certificate.crt')."
echo "        2.  Create a directory for them: sudo mkdir -p /usr/local/share/ca-certificates/dod"
echo "        3.  Copy the .crt files to this directory: sudo cp /path/to/your/dod_certs/*.crt /usr/local/share/ca-certificates/dod/"
echo "        4.  Update the system's certificate store: sudo update-ca-certificates"
echo ""
log_message "CAC installation script finished. Please proceed with the manual browser and certificate steps."
