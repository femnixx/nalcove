import QtQuick
import qs.components 1.0
import QtQuick.Controls


// Scratch notes (kept in memory while the island is running)
Card {
    id: root
    hoverEnabled: false
    Layout.fillWidth: true
    Layout.fillHeight: true

    Column {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.s2

            Text {
                text: "Notes"
                color: Theme.dim
                font.pixelSize: Theme.tSmall
                font.bold: true
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }

        Divider {}

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.rMd
            color: Theme.cardHi
            border.color: Theme.cardBorder
            border.width: 1

            TextEdit {
                id: edit
                anchors.fill: parent
                anchors.margins: Theme.s3
                color: Theme.fg
                font.pixelSize: Theme.tBody
                font.family: Theme.fontFamily
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                clip: true
            }

            Text {
                anchors.centerIn: parent
                visible: edit.text.length === 0 && !edit.activeFocus
                text: "Jot something down\u2026"
                color: Theme.dim
                font.pixelSize: Theme.tBody
                font.family: Theme.fontFamily
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onPressed: edit.forceActiveFocus()
                propagateComposedEvents: true
            }
        }
    }
}