import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications

Rectangle {
    id: root
    property real ui: 1
    color: Style.card
    radius: Style.cardRadius
    clip: true

    function s(px) { return Math.round(px * ui) }

    Column {
        anchors.fill: parent
        anchors.margins: s(16)
        spacing: s(12)

        Row {
            spacing: s(12)
            Text {
                text: "Notifications"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 18 * ui
                font.bold: true
            }
            Item { width: s(40) }
            Rectangle {
                width: s(100); height: s(28); radius: s(14)
                color: Style.cardHi
                border.color: Style.border; border.width: s(1)
                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12 * ui
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Notifications.clearAll()
                }
            }
        }

        ListView {
            width: parent.width
            height: parent.height - s(60)
            model: Notifications
            spacing: s(8)
            delegate: Rectangle {
                width: parent.width
                height: Math.max(s(72), content.implicitHeight + s(16))
                color: Style.cardHi
                radius: s(10)
                clip: true

                property bool hovered: false

                Column {
                    id: content
                    anchors.fill: parent
                    anchors.margins: s(16)
                    spacing: s(6)

                    Row {
                        spacing: s(12)
                        Rectangle {
                            width: s(40); height: s(40); radius: s(20)
                            color: (modelData.appIcon && modelData.appIcon !== "") ? "transparent" : Style.accent
                            Image {
                                anchors.fill: parent
                                source: modelData.appIcon || ""
                                fillMode: Image.PreserveAspectFit
                                visible: !!(modelData.appIcon && modelData.appIcon !== "")
                            }
                            Icon {
                                anchors.centerIn: parent
                                name: "bell"
                                size: s(20)
                                color: "white"
                                visible: !(modelData.appIcon && modelData.appIcon !== "")
                            }
                        }

                        Column {
                            spacing: s(2)
                            Text {
                                text: modelData.appName || "Unknown"
                                color: "#9a9aa0"
                                font.pixelSize: 11 * ui
                                font.bold: true
                            }
                            Text {
                                text: modelData.summary || ""
                                color: "#ffffff"
                                opacity: 1.0
                                font.pixelSize: 14 * ui
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.body || ""
                                color: "#9a9aa0"
                                font.pixelSize: 12 * ui
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Row {
                        spacing: s(8)
                        Item { width: s(52) }
                        Repeater {
                            model: modelData.actions || []
                            delegate: Item {
                                id: actionDelegate
                                property bool hovered: false
                                width: Math.max(s(60), actionText.implicitWidth + s(24))
                                height: s(30)

                                Rectangle {
                                    anchors.fill: parent
                                    radius: s(15)
                                    color: actionDelegate.hovered ? Style.accent : "transparent"
                                    border.color: Style.border; border.width: s(1)

                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: actionDelegate.hovered ? "white" : "#ffffff"
                                        opacity: 1.0
                                        font.pixelSize: 12 * ui
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

                        Item { width: s(40) }
                        Rectangle {
                            width: s(32); height: s(32); radius: s(16)
                            color: dismissDelegate.hovered ? "#ff453a20" : "transparent"
                            border.color: Style.border; border.width: s(1)
                            Icon {
                                anchors.centerIn: parent
                                name: "x"
                                size: s(14)
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
                font.pixelSize: 14 * ui
            }
        }
    }
}
