import QtQuick
import "../services" as Services
import qs.components 1.0

Item {
    // Main content area - Flickable for scrolling
    Flickable {
        anchors.fill: parent
        contentWidth: 360
        contentHeight: contentColumn.implicitHeight
        clip: true

        Column {
            id: contentColumn
            width: 360
            spacing: 16

            // ---- Output section ----
            Text { text: "Output"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }

            Row {
                width: parent.width; spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                DeviceSelector {
                    id: outputSelector
                    width: 140
                    anchors.verticalCenter: parent.verticalCenter
                    model: Services.Audio.sinks
                    currentNode: Services.Audio.sink
                    onPicked: n => Services.Audio.setDefaultSink(n)
                }

                Item {
                    width: 32; height: 32; anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        anchors.fill: parent; radius: 8; color: Services.Audio.sinkMuted ? "#3a3a3e" : "#1a1a1a"
                        border.color: "#33ffffff"; border.width: 1
                        Icon {
                            anchors.centerIn: parent; size: 16
                            name: Services.Audio.sinkMuted ? "volume-mute" : "volume"
                            color: Services.Audio.sinkMuted ? "#9a9aa0" : "#ffffff"
                        }
                        MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSinkMute() }
                    }
                }

                FlatSlider {
                    width: parent.width - 140 - 32 - 34 - 40
                    anchors.verticalCenter: parent.verticalCenter
                    value: Services.Audio.sinkVolume
                    enabled: Services.Audio.sinkReady
                    onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                }

                Text {
                    id: pctOut
                    width: 34; anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Audio.sinkVolume * 100); color: "#ffffff"; font.pixelSize: 12
                    horizontalAlignment: Text.AlignRight
                }
            }

            // ---- Input section ----
            Text { text: "Input"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }

            Row {
                width: parent.width; spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                DeviceSelector {
                    id: inputSelector
                    width: 140
                    anchors.verticalCenter: parent.verticalCenter
                    model: Services.Audio.sources
                    currentNode: Services.Audio.source
                    onPicked: n => Services.Audio.setDefaultSource(n)
                }

                Item {
                    width: 32; height: 32; anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        anchors.fill: parent; radius: 8; color: Services.Audio.sourceMuted ? "#3a3a3e" : "#1a1a1a"
                        border.color: "#33ffffff"; border.width: 1
                        Icon {
                            anchors.centerIn: parent; size: 16
                            name: Services.Audio.sourceMuted ? "volume-mute" : "volume"
                            color: Services.Audio.sourceMuted ? "#9a9aa0" : "#ffffff"
                        }
                        MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSourceMute() }
                    }
                }

                FlatSlider {
                    width: parent.width - 140 - 32 - 34 - 40
                    anchors.verticalCenter: parent.verticalCenter
                    value: Services.Audio.sourceVolume
                    enabled: Services.Audio.sourceReady
                    onMoved: if (Services.Audio.sourceReady) Services.Audio.setSourceVolume(value)
                }

                Text {
                    width: 34; anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Audio.sourceVolume * 100); color: "#ffffff"; font.pixelSize: 12
                    horizontalAlignment: Text.AlignRight
                }
            }

            // ---- Divider ----
            Rectangle {
                width: parent.width; height: 1; color: "#2a2a2e"
            }

            // ---- Per-app volume mixer ----
            AppMixer { width: parent.width }
        }
    }
}
