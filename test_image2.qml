import QtQuick
import QtQuick.Effects

Window {
    width: 400
    height: 400
    visible: true

    Image {
        id: img
        anchors.fill: parent
        source: "file:///mnt/hdd/Wallpapers/walls/a_cartoon_of_a_fire_face.png"
        sourceSize: Qt.size(1920, 1080)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        onStatusChanged: {
            if (status === Image.Error) {
                console.log("Error loading image:", source)
                console.log("Error string:", img.errorString)
                Qt.quit()
            } else if (status === Image.Ready) {
                console.log("Ready")
                Qt.quit()
            }
        }
    }
}
