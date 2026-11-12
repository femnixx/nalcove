import QtQuick

// Scratch notes (kept in memory while the island is running)
Rectangle {
    id: root
    property real ui: 1
    color: Style.card
    radius: Style.cardRadius

    function s(px) { return Math.round(px * ui) }

    Text {
        x: s(20); y: s(14)
        text: "NOTES"
        color: Style.dim
        font.pixelSize: 11 * ui
        font.bold: true
    }

    Rectangle {
        x: s(16); y: s(40)
        width: root.width - s(32); height: root.height - s(56)
        radius: s(12)
        color: "#1f1f23"

        TextEdit {
            id: edit
            anchors.fill: parent
            anchors.margins: s(12)
            color: Style.fg
            font.pixelSize: 14 * ui
            wrapMode: TextEdit.Wrap
            selectByMouse: true
            clip: true
        }
        Text {
            x: s(12); y: s(12)
            visible: edit.text.length === 0 && !edit.activeFocus
            text: "Jot something down..."
            color: Style.dim
            font.pixelSize: 14 * ui
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onPressed: edit.forceActiveFocus()
            propagateComposedEvents: true
        }
    }
}
