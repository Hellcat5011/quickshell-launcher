#!/usr/bin/env bash
# set-wallpaper.sh — set the wallpaper, then regenerate the Material You
# theme so the launcher's colors follow it.
#
# Usage: set-wallpaper.sh /path/to/image.jpg
# Called automatically by WallpaperSelector.qml — you generally don't
# need to run this by hand, but it's a plain script so you can.
set -euo pipefail

WALLPAPER="${1:?usage: set-wallpaper.sh <image path>}"

if ! command -v awww >/dev/null 2>&1; then
  echo "set-wallpaper.sh: 'awww' not found." >&2
  echo "Install awww, or edit this script to call hyprpaper/another tool instead." >&2
  exit 1
fi

# swww-daemon must already be running (usually started once via
# exec-once = swww-daemon in hyprland.conf).
awww img "$WALLPAPER" --transition-type random --transition-duration 1 --transition-fps 60

cp "$WALLPAPER" $HOME/.wa.jpg

if command -v matugen >/dev/null 2>&1; then
  # Regenerates every template configured in ~/.config/matugen/config.toml,
  # including data/colors.json that Theme.qml is watching.
  matugen image "$WALLPAPER" -m dark -t scheme-smart --source-color-index 0
  
  # Save the current wallpaper path for the App Launcher
  echo "$WALLPAPER" > "$(dirname "$0")/../data/current-wallpaper.txt"
  
  # Tell Quickshell to reload the theme (avoids polling)
  qs -c quickshell-launcher ipc call theme reload || true
else
  echo "set-wallpaper.sh: 'matugen' not found, theme not regenerated." >&2
  exit 1
fi
