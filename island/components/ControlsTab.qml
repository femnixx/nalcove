import QtQuick
import "../services" as Services
import qs.components 1.0 as Style

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

            // ---- Output section (matches image design) ----
            Text { text: "Output"; color: Style.dim; font.pixelSize: 11; font.bold: true }

            Row {
                width: parent.width; spacing: 8

                // Output name dropdown
                DeviceSelector {
                    id: outputSelector
                    width: 140
                    model: Services.Audio.sinks
                    currentNode: Services.Audio.sink
                    onPicked: n => Services.Audio.setDefaultSink(n)
                }

                // Mute button
                Item {
                    width: 32; height: 32; anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        anchors.fill: parent; radius: 8; color: Services.Audio.sinkMuted ? "#3a3a3e" : "#1a1a1a"
                        border.color: "#33ffffff"; border.width: 1
                        Icon {
                            anchors.centerIn: parent; size: 16
                            name: Services.Audio.sinkMuted ? "volume-mute" : "volume"
                            color: Services.Audio.sinkMuted ? Style.dim : Style.fg
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Services.Audio.toggleSinkMute()
                        }
                    }
                }

                // Volume slider
                FlatSlider {
                    anchors.verticalCenter: parent.verticalCenter
                    left: outputSelector.right; leftMargin: 8
                    right: pct.left; rightMargin: 8
                    value: Services.Audio.sinkVolume
                    enabled: Services.Audio.sinkReady
                    onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                }

                Text {
                    id: pct
                    width: 34; anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Audio.sinkVolume * 100); color: Style.fg; font.pixelSize: 12
                    horizontalAlignment: Text.AlignRight
                }
            }

            // ---- Per-app volume mixer ----
            AppMixer { width: parent.width }
        }
    }
}
