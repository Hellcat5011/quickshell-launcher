#!/bin/bash

# Define paths
SOURCE_DIR="/mnt/hdd/config/quickshell/quickshell-launcher/"
DEST_DIR="/home/vic/.config/quickshell/quickshell-launcher/"

# Ensure destination exists
mkdir -p "$DEST_DIR"

# Rsync files from the new dev environment to the live config.
# We exclude .git and tmp/ just in case, to avoid overriding the live repo state,
# though it's safe to sync everything.
echo "Syncing changes from $SOURCE_DIR to $DEST_DIR..."
rsync -av --exclude='.git' --exclude='tmp' "$SOURCE_DIR" "$DEST_DIR"

echo "Sync complete! You may need to restart quickshell for QML changes to fully take effect."
