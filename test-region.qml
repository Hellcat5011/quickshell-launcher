import Quickshell
import Quickshell.Wayland
import QtQml
import QtQuick

ShellRoot {
    PanelWindow {
        id: pw
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }
        
        WlrLayershell.mask: myRegion
        Region {
            id: myRegion
            item: rect
        }
        
        Rectangle {
            id: rect
            width: 100; height: 100
            color: "red"
        }
        
        Timer {
            interval: 2000
            running: true
            onTriggered: Quickshell.exit(0)
        }
    }
}
