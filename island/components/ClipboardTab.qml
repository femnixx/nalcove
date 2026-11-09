import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

    property string copyText: ""

    ListModel {
        id: clipboardModel
    }

    Process {
        id: pasteCmd
        command: ["wl-paste", "-t", "text"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    var t = text.trim()
                    var exists = false
                    for (var i = 0; i < clipboardModel.count; i++) {
                        if (clipboardModel.get(i).text === t) {
                            exists = true
                            break
                        }
                    }
                    if (!exists) {
                        clipboardModel.insert(0, { text: t, time: new Date().toLocaleTimeString() })
                        if (clipboardModel.count > 50) clipboardModel.remove(clipboardModel.count - 1)
                    }
                }
            }
        }
    }

    Process {
        id: copyProc
        command: ["wl-copy", root.copyText]
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: { pasteCmd.running = true }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Row {
            Layout.fillWidth: true
            spacing: 12
            Text {
                text: "Clipboard History"
                color: Theme.fg
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
                    color: Theme.dim
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: clipboardModel.clear()
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: clipboardModel
            spacing: 6
            delegate: Rectangle {
                width: parent.width
                height: Math.max(56, textItem.implicitHeight + 24)
                color: Theme.cardHi
                radius: 10
                clip: true

                property bool hovered: false

                Text {
                    id: textItem
                    width: parent.width - 80
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.text
                    color: Theme.fg
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        text: modelData.time
                        color: Theme.dim
                        font.pixelSize: 10
                    }

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: root.hovered ? Theme.accent : "transparent"
                        border.color: Theme.border; border.width: 1
                        Icon {
                            anchors.centerIn: parent
                            name: "copy"
                            size: 14
                            color: root.hovered ? "white" : Theme.dim
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.hovered = true
                            onExited: root.hovered = false
                            onClicked: {
                                root.copyText = modelData.text
                                copyProc.running = true
                            }
                        }
                    }

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: root.hovered ? "#ff453a20" : "transparent"
                        border.color: Theme.border; border.width: 1
                        Icon {
                            anchors.centerIn: parent
                            name: "trash"
                            size: 14
                            color: root.hovered ? "#ff453a" : Theme.dim
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.hovered = true
                            onExited: root.hovered = false
                            onClicked: clipboardModel.remove(index)
                        }
                    }
                }
            }
        }

        Item {
            visible: clipboardModel.count === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: Theme.dim
                font.pixelSize: 14
            }
        }
    }
}