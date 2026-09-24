# Quickshell Launcher

A modern, highly customizable, and minimal desktop launcher and widget collection built entirely with [Quickshell](https://quickshell.outfoxxed.me/). It features dynamic Material You theming and native Wayland support, delivering a seamless experience without relying on heavy external GUI tools.

> **⚠️ THIS IS A FULLY VIBE CODED PROJECT. IF YOU ARE UNCOMFORTABLE WITH THIS, PLEASE IGNORE THIS REPO. ⚠️**

## Features

- **App Launcher**: A fast, searchable application launcher with fuzzy finding.
- **Wallpaper Selector**: Built-in wallpaper picker that automatically updates system colors.
- **Power Menu**: Sleek system power controls.
- **Notification Center**: A unified hub for your system notifications.
- **Native Clipboard Manager**: A lightweight clipboard history viewer written purely in QML (no `cliphist` required).
- **Screen Capture**: Takes screenshots and screen recordings directly via Quickshell's Wayland APIs (no `grim`, `slurp`, or `wf-recorder` needed).
- **Keybind Viewer**: Dynamic on-screen display of your Hyprland keybindings.
- **MPRIS Media Player**: Integrates with your active media players, including generating video thumbnails.

## Dependencies

Make sure you have the following packages installed on your system before running the launcher.

### Core
- **[Quickshell](https://quickshell.outfoxxed.me/)**: The framework powering this project.
- **Qt6**: Standard Qt6 libraries required by Quickshell (e.g., `qt6-declarative`).

### System Tools
- **`wl-clipboard`**: Required for the clipboard manager daemon (`wl-paste`).
- **`playerctl`**: For MPRIS media player controls and widget support.
- **`pulseaudio-utils`** (or `pipewire-pulse`): Provides `pactl` for audio/volume management.
- **`bluez-utils`**: Provides `bluetoothctl` for Bluetooth status.

### Utilities
- **`jq`**: JSON processor used in various background scripts.
- **`ffmpeg`**: Used to extract thumbnails from local video files in the MPRIS widget.
- **`imagemagick`** (`magick`): Used for downscaling wallpaper previews for faster rendering.

### Theming & Background
- **`awww`** (or `swww`/`hyprpaper`): Used to set the desktop background. If you prefer a different tool, edit `scripts/set-wallpaper.sh`.
- **`matugen`**: Required for generating dynamic Material You color schemes based on your selected wallpaper.

## Installation & Setup

1. **Clone the repository** and move it into your Quickshell config directory:
   ```bash
   git clone <your-repo-url>
   mkdir -p ~/.config/quickshell
   mv quickshell-launcher ~/.config/quickshell/
   ```

2. **Start the Launcher** in the background:
   ```bash
   qs -c quickshell-launcher
   ```
   *(It is recommended to add this command to your compositor's autostart configuration, e.g., `exec-once = qs -c quickshell-launcher` in `hyprland.conf`)*

## IPC Commands (Keybind Integration)

You can trigger different modules by binding the following Quickshell IPC commands to shortcuts in your window manager (e.g., Hyprland, Sway):

| Module | Command |
| :--- | :--- |
| **App Launcher** | `qs -c quickshell-launcher ipc call launcher toggle` |
| **Wallpaper Picker** | `qs -c quickshell-launcher ipc call wallpaper toggle` |
| **Clipboard History** | `qs -c quickshell-launcher ipc call clipboard toggle` |
| **Power Menu** | `qs -c quickshell-launcher ipc call power toggle` |
| **Notification Center** | `qs -c quickshell-launcher ipc call notif toggle` |
| **Screenshot Tool** | `qs -c quickshell-launcher ipc call screenshot toggle` |
| **Screenshot Settings** | `qs -c quickshell-launcher ipc call screenshot settings toggle` |
| **Keybind Viewer** | `qs -c quickshell-launcher ipc call keybinds toggle` |

For a complete list of available IPC calls and options, run:
```bash
qs -c quickshell-launcher ipc call help display
```
