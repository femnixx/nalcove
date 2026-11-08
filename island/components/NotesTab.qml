import QtQuick

// Scratch notes (kept in memory while the island is running)
Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius

    Text {
        x: 20; y: 14
        text: "NOTES"
        color: Theme.dim
        font.pixelSize: 11
        font.bold: true
    }

    Rectangle {
        x: 16; y: 40
        width: root.width - 32; height: root.height - 56
        radius: 12
        color: "#1f1f23"

        TextEdit {
            id: edit
            anchors.fill: parent
            anchors.margins: 12
            color: Theme.fg
            font.pixelSize: 14
            wrapMode: TextEdit.Wrap
            selectByMouse: true
            clip: true
        }
        Text {
            x: 12; y: 12
            visible: edit.text.length === 0 && !edit.activeFocus
            text: "Jot something down..."
            color: Theme.dim
            font.pixelSize: 14
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onPressed: edit.forceActiveFocus()
            propagateComposedEvents: true
        }
    }
}
