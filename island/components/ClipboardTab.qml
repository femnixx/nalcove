import QtQuick
import "../services"

// Placeholder page for Clipboard tab (Phase N5 will fill it)
Item {
    id: root
    visible: false
    Rectangle {
        anchors.fill: parent
        color: Theme.card
        radius: Theme.cardRadius
        Text {
            anchors.centerIn: parent
            text: "Clipboard"
            color: Theme.dim
            font.pixelSize: 18
        }
    }
}