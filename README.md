A quickshell launcher that was fully vibe coded. 

It is a minimal launcher(To an extent), that has the following options:

- App launcher
- Wallpaper selector
- Power Menu
- Notification Center
- Clipboard (This is actually a full lightweight clipboard fully written in QML, not based on cliphist)

Install quickshell

Clone Repo, move folder to the ./config/quickshell folder.

In terminal run, qs -c quickshell-launcher

IPC calls:

- qs -c quickshell-launcher ipc call launcher toggle
- qs -c quickshell-launcher ipc call wallpaper toggle
- qs -c quickshell-launcher ipc call clipboard toggle
- qs -c quickshell-launcher ipc call power toggle
- qs -c quickshell-launcher ipc call notif toggle
