import Quickshell
import QtQml
import QtQuick
import QtQuick.Window

ShellRoot {
    PanelWindow {
        id: pw
        width: 100; height: 100
        Component.onCompleted: {
            console.log("Screen.devicePixelRatio: " + Screen.devicePixelRatio)
            Quickshell.exit(0)
        }
    }
}
