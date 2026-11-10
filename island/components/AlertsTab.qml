import QtQuick
import qs.components as Theme
import QtQuick.Layouts
import "../services" as Services


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
                text: "Notifications"
                color: Theme.fg
                font.pixelSize: Theme.tTitle
                font.bold: true
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Pill {
                text: "Clear All"
                danger: true
                enabled: Services.Notifications.count > 0
                Layout.alignment: Qt.AlignVCenter
                onClicked: Services.Notifications.clearAll()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: Services.Notifications.list
            spacing: Theme.s2
            clip: true

            delegate: Card {
                width: ListView.view.width
                hoverEnabled: true
                implicitHeight: Math.max(72, content.implicitHeight + Theme.s4 * 2)

                property bool hovered: false

                Column {
                    id: content
                    anchors.fill: parent
                    anchors.margins: Theme.s4
                    spacing: Theme.s2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.s3

                        Card {
                            width: 40; height: 40
                            radius: Theme.rMd
                            hoverEnabled: false
                            color: (modelData.appIcon && modelData.appIcon !== "") ? "transparent" : Theme.accentSoft

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                source: modelData.appIcon || ""
                                fillMode: Image.PreserveAspectFit
                                visible: !!(modelData.appIcon && modelData.appIcon !== "")
                            }
                            Icon {
                                anchors.centerIn: parent
                                name: "bell"
                                size: Theme.iconLg
                                color: Theme.accent
                                visible: !(modelData.appIcon && modelData.appIcon !== "")
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.appName || "Unknown"
                                color: Theme.dim
                                font.pixelSize: Theme.tSmall
                                font.bold: true
                                font.family: Theme.fontFamily
                            }
                            Text {
                                text: modelData.summary || ""
                                color: Theme.fg
                                font.pixelSize: Theme.tBody
                                font.bold: true
                                font.family: Theme.fontFamily
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.body || ""
                                color: Theme.dim
                                font.pixelSize: Theme.tSmall
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.s2

                        Item { Layout.fillWidth: true }

                        Repeater {
                            model: modelData.actions || []
                            delegate: Pill {
                                text: modelData.label
                                accent: true
                                height: Theme.controlH
                                onClicked: modelData.invoke()
                            }
                        }

                        Pill {
                            icon: "x"
                            iconOnly: true
                            danger: true
                            height: Theme.controlH
                            onClicked: modelData.dismiss()
                        }
                    }
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Services.Notifications.count === 0
            icon: "bell-off"
            text: "No notifications"
        }
    }
}