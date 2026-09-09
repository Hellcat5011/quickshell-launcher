import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects
import "../services"

PanelWindow {
    id: root
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 30
        right: 30
    }
    
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "desktop"
    
    implicitWidth: 400
    implicitHeight: 140
    color: "transparent"

    property var mprisData: ({})
    property bool isPlaying: mprisData.status === "Playing"

    function runPlayerCtl(cmd) {
        if (!root.mprisData.player) return;
        let p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["playerctl", "-p", root.mprisData.player, cmd];
        p.running = true;
    }

    Process {
        id: mprisProcess
        command: ["bash", Quickshell.shellDir + "/scripts/get-mpris.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.mprisData = JSON.parse(data)
                } catch(e) {}
            }
        }
    }

    DesktopWidgetBackground {}

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Album Art
        Rectangle {
            id: artContainer
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            radius: Theme.radiusSmall
            color: "transparent"
            clip: true

            function getFallbackSvg() {
                // We MUST url-encode the SVG, otherwise the '#' in Theme colors
                // breaks the data URI parser (it treats it as a URL fragment!)
                let c = Theme.background;
                let bg = Theme.primary;
                let raw = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                    <path fill="none" stroke="${c}" stroke-width="2" stroke-linejoin="miter" stroke-linecap="butt" d="M 16.50 8.85 L 19.78 6.55 A 9.5 9.5 0 1 1 17.45 4.22" />
                    <circle cx="12" cy="12" r="4.5" fill="${c}" />
                    <circle cx="12" cy="12" r="1.5" fill="${bg}" />
                </svg>`;
                return "data:image/svg+xml," + encodeURIComponent(raw);
            }

            Rectangle {
                id: backgroundRect
                width: 90
                height: 90
                anchors.centerIn: parent
                color: root.mprisData.artUrl ? "transparent" : Theme.primary
                radius: 10
                clip: true

                Image {
                    id: artImage
                    anchors.fill: parent
                    source: root.mprisData.artUrl || artContainer.getFallbackSvg()
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    layer.enabled: true
                    
                    // Prevent SVG pixelation by setting sourceSize to the exact render dimensions
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                    
                    // Small margin so it fills up more of the space
                    anchors.margins: root.mprisData.artUrl ? 0 : 5
                }
                
                Rectangle {
                    id: maskRect
                    anchors.fill: parent
                    radius: 10
                    visible: false
                    layer.enabled: true
                }
                
                MultiEffect {
                    source: artImage
                    anchors.fill: parent
                    maskEnabled: true
                    maskSource: maskRect
                }
            }

            // Equalizer overlay
            Row {
                anchors.centerIn: parent
                spacing: 4
                visible: root.isPlaying
                opacity: 0.7

                Repeater {
                    model: 5
                    Item {
                        width: 8
                        height: 50 // Max height constraint container
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: 10 + Math.random() * 30
                            radius: 4
                            color: Theme.primary
                            
                            SequentialAnimation on height {
                                loops: Animation.Infinite
                                running: root.isPlaying
                                NumberAnimation { to: 10 + Math.random() * 40; duration: 200 + Math.random() * 200; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 10 + Math.random() * 20; duration: 200 + Math.random() * 200; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                }
            }
        }

        // Media Info & Controls
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                Layout.fillWidth: true
                text: root.mprisData.title ? root.mprisData.title : "No Media"
                color: Theme.onPrimaryContainerColor
                font.family: "CaskaydiaCove Nerd Font Mono"
                font.bold: true
                font.pixelSize: 16
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.mprisData.artist ? root.mprisData.artist : ""
                color: Theme.onPrimaryContainerColor
                font.family: "CaskaydiaCove Nerd Font Mono"
                font.pixelSize: 14
                elide: Text.ElideRight
            }

            Item { Layout.fillHeight: true } // Spacer

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                // Previous
                Text {
                    text: "󰒮" 
                    font.family: "CaskaydiaCove Nerd Font Mono"
                    font.pixelSize: 24
                    color: Theme.onPrimaryContainerColor
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runPlayerCtl("previous")
                    }
                }

                // Play/Pause
                Text {
                    text: root.isPlaying ? "󰏤" : "󰐊" 
                    font.family: "CaskaydiaCove Nerd Font Mono"
                    font.pixelSize: 32
                    color: Theme.onPrimaryContainerColor
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runPlayerCtl("play-pause")
                    }
                }

                // Next
                Text {
                    text: "󰒭" 
                    font.family: "CaskaydiaCove Nerd Font Mono"
                    font.pixelSize: 24
                    color: Theme.onPrimaryContainerColor
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runPlayerCtl("next")
                    }
                }
            }
        }
    }
}
