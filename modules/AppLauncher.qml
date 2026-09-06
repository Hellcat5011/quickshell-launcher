// ─────────────────────────────────────────────────────────────────────────
// AppLauncher.qml — vertical list launcher
//
// Layout: search field → scrollable list of icon + name rows.
// Selection is highlighted with a rounded rect in Theme.primaryContainer.
// Keyboard: Up/Down to move, Enter to launch, Escape to close, type to
// filter. Mouse: hover to select, click to launch.
//
// Data source: Quickshell's built-in DesktopEntries singleton — reads
// every .desktop file on the system, no external binary needed.
// ─────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../services"

OverlayWindow {
    id: launcher
    panelWidth:  960
    panelHeight: 620
    cardRadius:  0 // Remove all rounding for the launcher

    property string currentWallpaperPath: "file:///home/vic/.wa.jpg"

    // Re-focus search and refresh the app list every time the panel opens.
    onShownChanged: {
        if (shown) {
            queryField.text = ""
            // Append timestamp to bypass image cache when wallpaper changes
            launcher.currentWallpaperPath = "file:///home/vic/.wa.jpg?t=" + Date.now()
            refreshApps()
            // Make sure the launcher always starts at the top of the list when opened
            launcher.selectedIndex = 0
            list.positionViewAtBeginning()
            queryField.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        // Trigger Quickshell's lazy-loading of .desktop files immediately on startup 
        // so they are ready by the time the user first opens the launcher.
        refreshApps()
    }

    property var allApps: []
    property var results:  []
    property int selectedIndex: 0

    function refreshApps() {
        const apps = []
        for (const entry of DesktopEntries.applications.values) {
            if (!entry.noDisplay) apps.push(entry)
        }
        apps.sort((a, b) => a.name.localeCompare(b.name))
        allApps = apps
        applyFilter()
    }

    function applyFilter() {
        const q = queryField.text.toLowerCase().trim()
        results = q.length === 0
            ? allApps
            : allApps.filter(e =>
                e.name.toLowerCase().includes(q) ||
                (e.genericName && e.genericName.toLowerCase().includes(q)) ||
                (e.keywords    && e.keywords.some(k => k.toLowerCase().includes(q))))
        selectedIndex = 0
    }

    function moveSelection(delta) {
        if (results.length === 0) return
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta))
        list.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function launch(entry) {
        if (!entry) return
        entry.execute()
        launcher.hide()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Left Side: Current Wallpaper ─────────────────────────────────
        Image {
            id: currentWall
            Layout.preferredWidth: 576
            Layout.fillHeight: true
            source: launcher.currentWallpaperPath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        // ── Right Side: App List ────────────────────────────────────────
        ColumnLayout {
            Layout.preferredWidth: 384
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: 12

            // ── Search field ────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: Theme.radiusSmall
                color:  Theme.surfaceVariant

                border.width: queryField.activeFocus ? 2 : 0
                border.color: Theme.primary
                Behavior on border.width { NumberAnimation { duration: Theme.animFast } }

                RowLayout {
                    anchors.fill:    parent
                    anchors.margins: 12
                    spacing: 8

                    // Magnifier glyph
                    Canvas {
                        width: 18; height: 18
                        Layout.alignment: Qt.AlignVCenter
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = Theme.surfaceVariantText
                            ctx.lineWidth   = 2
                            ctx.beginPath()
                            ctx.arc(7, 7, 5, 0, Math.PI * 2)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(11, 11)
                            ctx.lineTo(16, 16)
                            ctx.stroke()
                        }
                        Connections {
                            target: Theme
                            function onSurfaceVariantTextChanged() { searchIcon.requestPaint() }
                        }
                        id: searchIcon
                    }

                    TextInput {
                        id: queryField
                        Layout.fillWidth:    true
                        Layout.fillHeight:   true
                        verticalAlignment:   TextInput.AlignVCenter
                        font.pixelSize:      17
                        color:               Theme.surfaceText
                        clip:                true

                        onTextChanged: launcher.applyFilter()

                        Keys.onEscapePressed: launcher.hide()
                        Keys.onReturnPressed: launcher.launch(launcher.results[launcher.selectedIndex])
                        Keys.onEnterPressed:  launcher.launch(launcher.results[launcher.selectedIndex])
                        Keys.onDownPressed:   launcher.moveSelection(1)
                        Keys.onUpPressed:     launcher.moveSelection(-1)

                        Text {
                            visible:              queryField.text.length === 0
                            text:                 "Search apps…"
                            color:                Theme.surfaceVariantText
                            font:                 queryField.font
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // ── Result count hint ───────────────
            Text {
                visible:         queryField.text.length > 0
                text:            launcher.results.length + " result" + (launcher.results.length === 1 ? "" : "s")
                color:           Theme.surfaceVariantText
                font.pixelSize:  12
                Layout.leftMargin: 4
            }

            // ── App list ────────────────────────────────────────────────────
            ListView {
                id:               list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip:             true
                model:            launcher.results
                spacing:          4
                layer.enabled:    true

                delegate: Item {
                    width:  list.width
                    height: 54

                    Rectangle {
                        id: pill
                        anchors.fill:    parent
                        anchors.margins: 2
                        radius:          Theme.radiusSmall
                        color: (index === launcher.selectedIndex || hoverArea.containsMouse)
                               ? Qt.rgba(Theme.onPrimaryContainerColor.r, Theme.onPrimaryContainerColor.g, Theme.onPrimaryContainerColor.b, 0.85)
                               : "transparent"

                        RowLayout {
                            anchors.fill:    parent
                            anchors.leftMargin:  12
                            anchors.rightMargin: 12
                            spacing: 12

                            IconImage {
                                width:  32
                                height: 32
                                source: Quickshell.iconPath(modelData.icon)
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                Layout.fillWidth:    true
                                text:                modelData.name
                                color: (index === launcher.selectedIndex || hoverArea.containsMouse) ? Theme.inversePrimary : Theme.onPrimaryContainerColor
                                font.pixelSize:      15
                                elide:               Text.ElideRight
                                Layout.alignment:    Qt.AlignVCenter
                            }

                            Text {
                                visible:          modelData.genericName && modelData.genericName.length > 0
                                text:             modelData.genericName ?? ""
                                color: (index === launcher.selectedIndex || hoverArea.containsMouse) ? Qt.rgba(Theme.inversePrimary.r, Theme.inversePrimary.g, Theme.inversePrimary.b, 0.7) : Theme.surfaceVariantText
                                font.pixelSize:   12
                                elide:            Text.ElideRight
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    MouseArea {
                        id:           hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        // Only steal selection if the mouse actually moves, otherwise
                        // the selection will jump to the cursor instantly when the window opens.
                        onPositionChanged: launcher.selectedIndex = index
                        onClicked:    launcher.launch(modelData)
                    }
                }
            }
        }
    }
}

