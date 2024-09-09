#!/bin/bash

# Define the installation directory
INSTALL_DIR="$HOME/g57-local-assistant-be"

# Define the program folder
PROGRAM_FOLDER="$HOME/g57-program-files"
FILE_EXECUTE_PROGRAM="g57-copilot-local.sh"

# Define the ZIP file
ZIP_FILE="g57-local-assistant-be-release.zip"

# Define the URL
URL_TO_DOWNLOAD_APP="https://github.com/jorgexxx/g57-copilot-local-public/raw/master/g57-local-assistant-be-release.zip"

# Delete previous files
echo "Deleting previous files..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi
if [ -f "$ZIP_FILE" ]; then
    rm "$ZIP_FILE"
fi

# Stop current processes on port 30101
echo "Stopping current processes on port 30101..."
kill -9 $(lsof -t -i:30101 -sTCP:LISTEN)

# Dowload ZIP file
echo "Downloading the ZIP file..."
wget -O "$ZIP_FILE" "$URL_TO_DOWNLOAD_APP"
echo "Download completed."

# Unzip the ZIP
echo "Decompressing the ZIP file..."
unzip -o "$ZIP_FILE" -d "$HOME"
echo "Decompression completed."

# Verify the existence of the program folder
if [ ! -d "$PROGRAM_FOLDER" ]; then
    echo "Error: The folder '$PROGRAM_FOLDER' does not exist. Verify that the download and decompression were successful."
    exit 1
fi

# Create the installation directory (if it doesn't exist)
mkdir -p "$INSTALL_DIR"

# Copy files to the installation directory
# dist package.json package-lock.json README.md .env.pro
cp -r $PROGRAM_FOLDER/* "$INSTALL_DIR/"
cp -r $PROGRAM_FOLDER/.env.pro "$INSTALL_DIR/"

# Get the desktop path
DESKTOP_PATH=$(xdg-user-dir DESKTOP)

if [ ! -d "$DESKTOP_PATH" ]; then
    echo "Desktop folder not found."
    exit 1
fi

# Create the desktop shortcut script
DESKTOP_SCRIPT="$DESKTOP_PATH/$FILE_EXECUTE_PROGRAM"
cat > "$DESKTOP_SCRIPT" << EOL
#!/bin/bash

# Load nvm
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"

# Run the backend
cd "$INSTALL_DIR" && npm run pro

# Keep the terminal window open
exec \$SHELL
EOL

# Copy "DESKTOP_SCRIPT" file to the same location as "install.sh" as well.
cp "$DESKTOP_SCRIPT" "$FILE_EXECUTE_PROGRAM"

# Make the desktop script executable
chmod +x "$DESKTOP_SCRIPT" "$FILE_EXECUTE_PROGRAM"

echo "Installation completed. You can run the backend by double-clicking the '$FILE_EXECUTE_PROGRAM' script on your desktop."

# Keep the terminal window open
exec $SHELL