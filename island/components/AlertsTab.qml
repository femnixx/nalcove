import QtQuick
import "../services"

// Placeholder page for Alerts tab (Phase N6 will fill it)
Item {
    id: root
    visible: false
    Rectangle {
        anchors.fill: parent
        color: Theme.card
        radius: Theme.cardRadius
        Text {
            anchors.centerIn: parent
            text: "Alerts"
            color: Theme.dim
            font.pixelSize: 18
        }
    }
}