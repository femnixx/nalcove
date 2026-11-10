import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    Column {
        anchors.fill: parent
        anchors.margins: Style.s4
        spacing: Style.s3

        // DND toggle
        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            RowLayout {
                anchors.fill: parent
                anchors.margins: Style.s4
                spacing: Style.s3

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Do Not Disturb"
                        color: Style.fg
                        font.pixelSize: Style.tBody
                        font.family: Style.fontFamily
                    }
                    Text {
                        text: "Suppress notification peeks"
                        color: Style.dim
                        font.pixelSize: Style.tSmall
                        font.family: Style.fontFamily
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
                anchors.margins: Style.s4
                spacing: Style.s3

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Notification History"
                        color: Style.fg
                        font.pixelSize: Style.tBody
                        font.family: Style.fontFamily
                    }
                    Text {
                        text: "Max items: " + Services.Notifications.maxItems
                        color: Style.dim
                        font.pixelSize: Style.tSmall
                        font.family: Style.fontFamily
                    }
                }

                Row {
                    spacing: Style.s2
                    Pill {
                        text: "−"
                        height: Style.controlH
                        onClicked: Services.Notifications.maxItems = Math.max(10, Services.Notifications.maxItems - 10)
                    }
                    Pill {
                        text: "+"
                        height: Style.controlH
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
                anchors.margins: Style.s4
                spacing: Style.s2

                Text {
                    text: "Appearance"
                    color: Style.dim
                    font.pixelSize: Style.tSmall
                    font.bold: true
                    font.family: Style.fontFamily
                }

                Row {
                    spacing: Style.s2
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
                anchors.margins: Style.s4
                spacing: Style.s2

                Text {
                    text: "About"
                    color: Style.dim
                    font.pixelSize: Style.tSmall
                    font.bold: true
                    font.family: Style.fontFamily
                }

                Text {
                    text: "Dynamic Notch for Niri"
                    color: Style.fg
                    font.pixelSize: Style.tBody
                    font.family: Style.fontFamily
                }

                Text {
                    text: "Built with Quickshell & Qt Quick"
                    color: Style.dim
                    font.pixelSize: Style.tSmall
                    font.family: Style.fontFamily
                }
            }
        }

        Item { Layout.fillHeight: true; visible: false }
    }
}