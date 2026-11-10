import QtQuick
import qs.components 1.0
import QtQuick.Controls
import QtQuick.Layouts


Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    Column {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        // DND toggle
        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.s4
                spacing: Theme.s3

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Do Not Disturb"
                        color: Theme.fg
                        font.pixelSize: Theme.tBody
                        font.family: Theme.fontFamily
                    }
                    Text {
                        text: "Suppress notification peeks"
                        color: Theme.dim
                        font.pixelSize: Theme.tSmall
                        font.family: Theme.fontFamily
                    }
                }

                Switch {
                    checked: Services.Notifications.dnd
                    onToggled: Services.Notifications.setDnd(checked)
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        Divider {}

        // Notification history limit
        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.s4
                spacing: Theme.s3

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Notification History"
                        color: Theme.fg
                        font.pixelSize: Theme.tBody
                        font.family: Theme.fontFamily
                    }
                    Text {
                        text: "Max items: " + Services.Notifications.maxItems
                        color: Theme.dim
                        font.pixelSize: Theme.tSmall
                        font.family: Theme.fontFamily
                    }
                }

                Row {
                    spacing: Theme.s2
                    Pill {
                        text: "−"
                        height: Theme.controlH
                        onClicked: Services.Notifications.maxItems = Math.max(10, Services.Notifications.maxItems - 10)
                    }
                    Pill {
                        text: "+"
                        height: Theme.controlH
                        onClicked: Services.Notifications.maxItems = Math.min(200, Services.Notifications.maxItems + 10)
                    }
                }
            }
        }

        Divider {}

        // Theme info
        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            Column {
                anchors.fill: parent
                anchors.margins: Theme.s4
                spacing: Theme.s2

                Text {
                    text: "Appearance"
                    color: Theme.dim
                    font.pixelSize: Theme.tSmall
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                Row {
                    spacing: Theme.s2
                    Pill { text: "Light"; onClicked: console.log("Light theme not implemented") }
                    Pill { text: "Dark"; onClicked: console.log("Dark theme not implemented") }
                    Pill { text: "System"; onClicked: console.log("System theme not implemented") }
                }
            }
        }

        Divider {}

        // About
        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            Column {
                anchors.fill: parent
                anchors.margins: Theme.s4
                spacing: Theme.s2

                Text {
                    text: "About"
                    color: Theme.dim
                    font.pixelSize: Theme.tSmall
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                Text {
                    text: "Dynamic Notch for Niri"
                    color: Theme.fg
                    font.pixelSize: Theme.tBody
                    font.family: Theme.fontFamily
                }

                Text {
                    text: "Built with Quickshell & Qt Quick"
                    color: Theme.dim
                    font.pixelSize: Theme.tSmall
                    font.family: Theme.fontFamily
                }
            }
        }

        Item { Layout.fillHeight: true; visible: false }
    }
}