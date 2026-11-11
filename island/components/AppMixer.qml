import QtQuick
import Quickshell
import "../services" as Services

Column {
    id: mixer
    width: parent ? parent.width : 360
    spacing: 8
    visible: Services.Audio.appStreams.length > 0

    Text { text: "Applications"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }

    Repeater {
        model: Services.Audio.appStreams
        delegate: Item {
            id: row
            required property var modelData
            readonly property var node: modelData
            property bool opened: false
            width: mixer.width
            height: 56

            Image {
                id: appIcon
                x: 0; anchors.verticalCenter: parent.verticalCenter
                width: 28; height: 28
                sourceSize: Qt.size(56, 56)
                asynchronous: true
                source: Quickshell.iconPath(Services.Audio.appIconName(row.node), "audio-x-generic")
                opacity: row.node.audio && row.node.audio.muted ? 0.4 : 1
                MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleNodeMute(row.node) }
            }

            Column {
                id: labels
                anchors.left: appIcon.right; anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 120
                spacing: 1
                Text { width: parent.width; text: Services.Audio.appName(row.node); color: "#ffffff"; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight }
                Text { width: parent.width; text: Services.Audio.appDetail(row.node); color: "#9a9aa0"; font.pixelSize: 10; elide: Text.ElideRight; visible: text !== "" }
            }

            FlatSlider {
                anchors.left: labels.right; anchors.leftMargin: 10
                anchors.right: outputBtn.left; anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                value: row.node.audio ? row.node.audio.volume : 0
                enabled: row.node.audio !== null
                onMoved: Services.Audio.setNodeVolume(row.node, value)
            }

            // Per-app output selector dropdown
            Item {
                id: outputBtn
                anchors.right: pct.left; anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 120; height: 32

                Rectangle {
                    id: outputHeader
                    width: parent.width; height: parent.height; radius: 8; color: "#1a1a1a"
                    border.color: "#2a2a2a"; border.width: 1

                    Text {
                        id: outputLabel
                        anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8
                        anchors.right: parent.right; anchors.rightMargin: 24
                        text: row.opened ? "Select output..." : (row.node.name); color: "#9a9aa0"; font.pixelSize: 10
                        elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        anchors.right: parent.right; anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.opened ? "▴" : "▾"; color: "#9a9aa0"; font.pixelSize: 10
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { row.opened = !row.opened }
                    }
                }

                // Dropdown list of sinks
                Rectangle {
                    id: outputDropdown
                    y: outputHeader.height
                    width: parent.width
                    height: Math.min(sinkList.implicitHeight + 8, 120)
                    radius: 8; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1
                    clip: true
                    visible: row.opened
                    z: 50
                    layer.enabled: true

                    Flickable {
                        anchors.fill: parent; anchors.margins: 4
                        clip: true; boundsBehavior: Flickable.StopAtBounds
                        interactive: sinkList.height > outputDropdown.height - 8

                        Column {
                            id: sinkList
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: Services.Audio.sinks
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 26
                                    radius: 6
                                    property bool isCur: modelData.name === row.node.name
                                    color: ma.containsMouse ? "#2a2a2a" : "transparent"
                                    Text {
                                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                                        text: modelData.description || modelData.name
                                        color: parent.isCur ? "#3b8bff" : "#ffffff"
                                        font.pixelSize: 10
                                        elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                                    }
                                    MouseArea {
                                        id: ma
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            Services.Audio.moveStreamToSink(row.node, modelData.name)
                                            row.opened = false
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: !Services.Audio.sinks || Services.Audio.sinks.length === 0
                                text: "No outputs"; color: "#9a9aa0"; font.pixelSize: 10
                                height: 26; verticalAlignment: Text.AlignVCenter; leftPadding: 8
                            }
                        }
                    }
                }
            }

            Text {
                id: pct
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                width: 34; horizontalAlignment: Text.AlignRight
                text: row.node.audio ? Math.round(row.node.audio.volume * 100) : 0
                color: "#ffffff"; font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                onClicked: row.opened = false
                propagateComposedEvents: true
            }
        }
    }
}
