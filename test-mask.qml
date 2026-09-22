import Quickshell
import Quickshell.Wayland
import QtQml
import QtQuick

ShellRoot {
    PanelWindow {
        id: pw
        WlrLayershell.layer: WlrLayer.Overlay
        color: "red"
        anchors { top: true; bottom: true; left: true; right: true }
        
        mask: emptyRegion
        Region { id: emptyRegion }
        
        Timer {
            interval: 2000
            running: true
            onTriggered: Quickshell.exit(0)
        }
    }
}
