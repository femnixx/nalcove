import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Item {
    id: root
    property real ui: 1
    Layout.fillWidth: true
    Layout.fillHeight: true

    Column {
        anchors.fill: parent
        anchors.margins: Style.s4 * ui
        spacing: Style.s3 * ui

        // DND toggle
        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            RowLayout {
                anchors.fill: parent
                anchors.margins: Style.s4 * ui
                spacing: Style.s3 * ui

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Do Not Disturb"
                        color: Style.fg
                        font.pixelSize: Style.tBody * ui
                        font.family: Style.fontFamily
                    }
                    Text {
                        text: "Suppress notification peeks"
                        color: Style.dim
                        font.pixelSize: Style.tSmall * ui
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
                anchors.margins: Style.s4 * ui
                spacing: Style.s3 * ui

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Notification History"
                        color: Style.fg
                        font.pixelSize: Style.tBody * ui
                        font.family: Style.fontFamily
                    }
                    Text {
                        text: "Max items: " + Services.Notifications.maxItems
                        color: Style.dim
                        font.pixelSize: Style.tSmall * ui
                        font.family: Style.fontFamily
                    }
                }

                Row {
                    spacing: Style.s2 * ui
                    Pill { ui: root.ui
                        text: "−"
                        height: Style.controlH * ui
                        onClicked: Services.Notifications.maxItems = Math.max(10, Services.Notifications.maxItems - 10)
                    }
                    Pill { ui: root.ui
                        text: "+"
                        height: Style.controlH * ui
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
                anchors.margins: Style.s4 * ui
                spacing: Style.s2 * ui

                Text {
                    text: "Appearance"
                    color: Style.dim
                    font.pixelSize: Style.tSmall * ui
                    font.bold: true
                    font.family: Style.fontFamily
                }

                Row {
                    spacing: Style.s2 * ui
                    Pill { ui: root.ui text: "Light"; onClicked: console.log("Light theme not implemented") }
                    Pill { ui: root.ui text: "Dark"; onClicked: console.log("Dark theme not implemented") }
                    Pill { ui: root.ui text: "System"; onClicked: console.log("System theme not implemented") }
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
                anchors.margins: Style.s4 * ui
                spacing: Style.s2 * ui

                Text {
                    text: "About"
                    color: Style.dim
                    font.pixelSize: Style.tSmall * ui
                    font.bold: true
                    font.family: Style.fontFamily
                }

                Text {
                    text: "Dynamic Notch for Niri"
                    color: Style.fg
                    font.pixelSize: Style.tBody * ui
                    font.family: Style.fontFamily
                }

                Text {
                    text: "Built with Quickshell & Qt Quick"
                    color: Style.dim
                    font.pixelSize: Style.tSmall * ui
                    font.family: Style.fontFamily
                }
            }
        }

        Item { Layout.fillHeight: true; visible: false }
    }
}