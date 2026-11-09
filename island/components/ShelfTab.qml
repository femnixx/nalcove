import QtQuick
import "../services"

// Placeholder page for Shelf tab (Phase N7 will fill it)
Item {
    id: root
    visible: false
    Rectangle {
        anchors.fill: parent
        color: Theme.card
        radius: Theme.cardRadius
        Text {
            anchors.centerIn: parent
            text: "Shelf"
            color: Theme.dim
            font.pixelSize: 18
        }
    }
}