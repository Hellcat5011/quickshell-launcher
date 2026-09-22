import Quickshell
import QtQml
import QtQuick
import QtQuick.Window

ShellRoot {
    Component.onCompleted: {
        console.log("Screens: " + Quickshell.screens.length)
        var s = Quickshell.screens[0]
        for (var prop in s) {
            console.log(prop + ": " + s[prop])
        }
    }
}
