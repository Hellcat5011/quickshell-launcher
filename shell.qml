//@ pragma UseQApplication
// ─────────────────────────────────────────────────────────────────────────
// shell.qml — Quickshell entry point
//
// Run this with (from anywhere):
//   qs -c quickshell-launcher
// assuming this whole folder is placed at
//   ~/.config/quickshell/quickshell-launcher
//
// or point at it directly without installing it anywhere in particular:
//   qs -p /path/to/this/folder/shell.qml
//
// ShellRoot is just a container — it doesn't draw anything itself, it
// just holds the windows/singletons that make up your shell. Quickshell
// keeps this process running in the background (e.g. via `exec-once` in
// hyprland.conf) and both windows below stay hidden until toggled.
// ─────────────────────────────────────────────────────────────────────────
import Quickshell
import Quickshell.Io
import QtQml
import "modules" as Modules
import "services"

ShellRoot {
    Component.onCompleted: {
        Quickshell.iconTheme = "Slot-Gray-Dark-Icons"
    }

    // Launch custom clipboard watchers
    Process {
        command: ["sh", Quickshell.shellDir + "/scripts/clipboard-daemon.sh"]
        running: true
    }

    Modules.AppLauncher {
        id: appLauncher
    }

    Modules.WallpaperSelector {
        id: wallpaperSelector
    }

    Modules.NotificationCenter {
        id: notificationCenter
    }

    Modules.NotificationPopup {
        id: notificationPopup
    }

    Modules.Osd {
        id: osd
    }

    Modules.ClipboardManager {
        id: clipboardManager
    }

    Modules.PowerMenu {
        id: powerMenu
    }

    Modules.DesktopMpris {
        id: desktopMpris
    }

    Modules.DesktopTray {
        id: desktopTray
    }

    Modules.DesktopClock {
        id: desktopClock
    }

    Modules.DesktopCalendar {
        id: desktopCalendar
    }

    // IPC handlers: these let you (or a Hyprland keybind) control the
    // windows above from a terminal, e.g.:
    //   qs -c quickshell-launcher ipc call launcher toggle
    //   qs -c quickshell-launcher ipc call wallpaper toggle
    // See hypr/launcher-binds.conf for ready-made Hyprland keybinds.
    IpcHandler {
        target: "launcher"
        function toggle(): void { appLauncher.toggle() }
        function open(): void { appLauncher.show() }
        function close(): void { appLauncher.hide() }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { wallpaperSelector.toggle() }
        function open(): void { wallpaperSelector.show() }
        function close(): void { wallpaperSelector.hide() }
    }

    IpcHandler {
        target: "theme"
        function reload(): void {
            Theme.forceReload()
        }
    }

    IpcHandler {
        target: "notif"
        function toggle(): void { notificationCenter.toggle() }
        function open(): void { notificationCenter.show() }
        function close(): void { notificationCenter.hide() }
    }

    IpcHandler {
        target: "osd"
        function volume(val: string): void { osd.showOsd("volume", val) }
        function brightness(val: string): void { osd.showOsd("brightness", val) }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { clipboardManager.toggle() }
        function open(): void { clipboardManager.show() }
        function close(): void { clipboardManager.hide() }
    }

    IpcHandler {
        target: "power"
        function toggle(): void { powerMenu.toggle() }
        function open(): void { powerMenu.show() }
        function close(): void { powerMenu.hide() }
    }
}
