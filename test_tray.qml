import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

PanelWindow {
    width: 100; height: 100
    Component.onCompleted: {
        console.log("has SystemTrayItem: " + (typeof SystemTrayItem !== "undefined"));
        Quickshell.exit(0)
    }
}
