import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../services"

OverlayWindow {
    id: clipboard
    panelWidth:  800
    panelHeight: 600
    cardRadius:  Theme.radiusLarge
    
    // Refresh when shown
    onShownChanged: {
        if (shown) {
            queryField.text = ""
            refreshClipboard()
            clipboard.selectedIndex = 0
            list.positionViewAtBeginning()
            queryField.forceActiveFocus()
        }
    }

    property var allItems: []
    property var results:  []
    property int selectedIndex: 0

    function refreshClipboard() {
        cliphistListProcess.running = true
    }

    function applyFilter() {
        const q = queryField.text.toLowerCase().trim()
        results = q.length === 0
            ? allItems
            : allItems.filter(e => e.content.toLowerCase().includes(q))
        selectedIndex = 0
    }

    function moveSelection(delta) {
        if (results.length === 0) return
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta))
        list.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function copyItem(entry) {
        if (!entry) return
        if (entry.isImage) {
            // Remove 'file://' prefix to get raw path
            const rawPath = entry.imagePath.replace("file://", "")
            copyProcess.command = ["sh", "-c", `wl-copy -t image/png < ${rawPath}`]
        } else {
            // Write text to a temporary file, then copy it to avoid escaping issues
            const tmpPath = "/tmp/quickshell-clip-tmp.txt"
            Quickshell.Io.File.write(tmpPath, entry.content)
            copyProcess.command = ["sh", "-c", `wl-copy < ${tmpPath}`]
        }
        copyProcess.running = true
        clipboard.hide()
    }

    // Process to read clipboard json
    property Process cliphistListProcess: Process {
        id: cliphistListProcess
        command: ["cat", Quickshell.env("HOME") + "/.cache/quickshell-clipboard.json"]
        property string fullOutput: ""
        
        onRunningChanged: {
            if (running) {
                fullOutput = ""
            } else {
                try {
                    const newItems = JSON.parse(fullOutput)
                    clipboard.allItems = newItems
                    clipboard.applyFilter()
                } catch (e) {
                    console.warn("Could not parse clipboard JSON:", e)
                }
            }
        }
        
        stdout: SplitParser {
            onRead: data => {
                cliphistListProcess.fullOutput += data + "\n"
            }
        }
    }

    property Process copyProcess: Process {
        id: copyProcess
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Search Field
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: Theme.surfaceVariant
            radius: Theme.radiusSmall
            border.width: queryField.activeFocus ? 2 : 1
            border.color: queryField.activeFocus ? Theme.primary : Theme.outlineVariant

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: "Search Clipboard..."
                    color: Theme.surfaceVariantText
                    font.pixelSize: 16
                    visible: queryField.text.length === 0
                    Layout.fillWidth: true
                }
            }

            TextInput {
                id: queryField
                anchors.fill: parent
                anchors.margins: 12
                color: Theme.surfaceText
                font.pixelSize: 16
                verticalAlignment: TextInput.AlignVCenter
                clip: true

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Up) {
                        clipboard.moveSelection(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        clipboard.moveSelection(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        clipboard.copyItem(clipboard.results[clipboard.selectedIndex])
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        clipboard.hide()
                        event.accepted = true
                    }
                }

                onTextChanged: clipboard.applyFilter()
            }
        }

        // List View
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: clipboard.results
            currentIndex: clipboard.selectedIndex

            delegate: Rectangle {
                id: delegateRect
                width: ListView.view.width
                height: itemLayout.implicitHeight + 24
                radius: Theme.radiusSmall
                
                property bool isSelected: index === clipboard.selectedIndex
                
                color: isSelected ? Theme.primaryContainer : "transparent"
                border.width: 1
                border.color: isSelected ? Theme.primary : Theme.outlineVariant

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: clipboard.selectedIndex = index
                    onClicked: clipboard.copyItem(modelData)
                }

                ColumnLayout {
                    id: itemLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Text Content
                    Text {
                        Layout.fillWidth: true
                        text: modelData.content
                        color: delegateRect.isSelected ? Theme.onPrimaryContainerColor : Theme.surfaceText
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        maximumLineCount: 10
                        elide: Text.ElideRight
                        visible: !modelData.isImage
                    }

                    // Image Content (Thumbnail)
                    Image {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        visible: modelData.isImage
                        source: modelData.isImage ? modelData.imagePath : ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                }
            }
            
            ScrollBar.vertical: ScrollBar {}
        }
    }
}
