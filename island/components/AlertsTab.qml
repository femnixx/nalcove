import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Row {
            spacing: 12
            Text {
                text: "Notifications"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 18
                font.bold: true
            }
            Item { width: 40 }
            Rectangle {
                width: 100; height: 28; radius: 14
                color: Theme.cardHi
                border.color: Theme.border; border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Notifications.clearAll()
                }
            }
        }

        ListView {
            width: parent.width
            height: parent.height - 60
            model: Notifications
            spacing: 8
            delegate: Rectangle {
                width: parent.width
                height: Math.max(72, content.implicitHeight + 16)
                color: Theme.cardHi
                radius: 10
                clip: true

                property bool hovered: false

                Column {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 6

                    Row {
                        spacing: 12
                        Rectangle {
                            width: 40; height: 40; radius: 20
                            color: (modelData.appIcon && modelData.appIcon !== "") ? "transparent" : Theme.accent
                            Image {
                                anchors.fill: parent
                                source: modelData.appIcon || ""
                                fillMode: Image.PreserveAspectFit
                                visible: !!(modelData.appIcon && modelData.appIcon !== "")
                            }
                            Icon {
                                anchors.centerIn: parent
                                name: "bell"
                                size: 20
                                color: "white"
                                visible: !(modelData.appIcon && modelData.appIcon !== "")
                            }
                        }

                        Column {
                            spacing: 2
                            Text {
                                text: modelData.appName || "Unknown"
                                color: "#9a9aa0"
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                text: modelData.summary || ""
                                color: "#ffffff"
                                opacity: 1.0
                                font.pixelSize: 14
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.body || ""
                                color: "#9a9aa0"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Row {
                        spacing: 8
                        Item { width: 52 }
                        Repeater {
                            model: modelData.actions || []
                            delegate: Item {
                                id: actionDelegate
                                property bool hovered: false
                                width: Math.max(60, actionText.implicitWidth + 24)
                                height: 30

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 15
                                    color: actionDelegate.hovered ? Theme.accent : "transparent"
                                    border.color: Theme.border; border.width: 1

                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: actionDelegate.hovered ? "white" : "#ffffff"
                                        opacity: 1.0
                                        font.pixelSize: 12
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: actionDelegate.hovered = true
                                    onExited: actionDelegate.hovered = false
                                    onClicked: modelData.invoke()
                                }
                            }
                        }

                        Item { width: 40 }
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: dismissDelegate.hovered ? "#ff453a20" : "transparent"
                            border.color: Theme.border; border.width: 1
                            Icon {
                                anchors.centerIn: parent
                                name: "x"
                                size: 14
                                color: dismissDelegate.hovered ? "#ff453a" : "#9a9aa0"
                            }
                            MouseArea {
                                id: dismissDelegate
                                anchors.fill: parent
                                hoverEnabled: true
                                property bool hovered: false
                                onEntered: dismissDelegate.hovered = true
                                onExited: dismissDelegate.hovered = false
                                onClicked: modelData.dismiss()
                            }
                        }
                    }
                }
            }
        }

        Item {
            visible: Notifications.length === 0
            anchors.fill: parent
            Text {
                anchors.centerIn: parent
                text: "No notifications"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 14
            }
        }
    }
}