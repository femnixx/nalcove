import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"


Item {
    id: root

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentColumn.implicitHeight
        clip: true

        ScrollIndicator { flickable: parent }

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.s3

            // Output section
            Text {
                text: "Output"
                color: Theme.dim
                font.pixelSize: Theme.tSmall
                font.bold: true
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                leftPadding: Theme.s4
            }

            Card {
                Layout.fillWidth: true
                hoverEnabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.s4
                    spacing: Theme.s3

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumHeight: Theme.controlH
                        Layout.preferredHeight: Theme.controlH
                        spacing: Theme.s2

                        Item {
                            width: Theme.iconMd + Theme.s2; height: Theme.controlH
                            Icon { name: "volume"; size: Theme.iconMd; anchors.centerIn: parent; opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }
                            MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSinkMute() }
                        }

                        FlatSlider {
                            Layout.fillWidth: true
                            value: Services.Audio.sinkVolume
                            enabled: Services.Audio.sinkReady
                            onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                        }

                        Text {
                            width: 34
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            text: Math.round(Services.Audio.sinkVolume * 100)
                            color: Theme.fg
                            font.pixelSize: Theme.tBody
                            font.family: Theme.fontFamily
                        }
                    }

                    DeviceSelector {
                        id: outputSelector
                        Layout.fillWidth: true
                        accordionGroup: true
                        model: Services.Audio.sinks
                        currentNode: Services.Audio.sink
                        onPicked: n => Services.Audio.setDefaultSink(n)
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.cardBorder
            }

            // Input section
            Text {
                text: "Input"
                color: Theme.dim
                font.pixelSize: Theme.tSmall
                font.bold: true
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                leftPadding: Theme.s4
            }

            Card {
                Layout.fillWidth: true
                hoverEnabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.s4
                    spacing: Theme.s3

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumHeight: Theme.controlH
                        Layout.preferredHeight: Theme.controlH
                        spacing: Theme.s2

                        Item {
                            width: Theme.iconMd + Theme.s2; height: Theme.controlH
                            Icon { name: "volume"; size: Theme.iconMd; anchors.centerIn: parent; color: Services.Audio.sourceMuted ? Theme.danger : Theme.fg }
                            MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSourceMute() }
                        }

                        FlatSlider {
                            Layout.fillWidth: true
                            value: Services.Audio.sourceVolume
                            enabled: Services.Audio.sourceReady
                            onMoved: if (Services.Audio.sourceReady) Services.Audio.setSourceVolume(value)
                        }

                        Text {
                            width: 34
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            text: Math.round(Services.Audio.sourceVolume * 100)
                            color: Theme.fg
                            font.pixelSize: Theme.tBody
                            font.family: Theme.fontFamily
                        }
                    }

                    DeviceSelector {
                        id: inputSelector
                        Layout.fillWidth: true
                        accordionGroup: true
                        model: Services.Audio.sources
                        currentNode: Services.Audio.source
                        onPicked: n => Services.Audio.setDefaultSource(n)
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.cardBorder; visible: Services.Brightness.available }

            // Per-app volume mixer
            AppMixer { Layout.fillWidth: true }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.cardBorder; visible: Services.Brightness.available }

            // Brightness section
            Text {
                visible: Services.Brightness.available
                text: "Brightness"
                color: Theme.dim
                font.pixelSize: Theme.tSmall
                font.bold: true
                font.family: Theme.fontFamily
                Layout.fillWidth: true
                leftPadding: Theme.s4
            }

            Card {
                visible: Services.Brightness.available
                Layout.fillWidth: true
                hoverEnabled: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.s4
                    spacing: Theme.s3

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumHeight: Theme.controlH
                        Layout.preferredHeight: Theme.controlH
                        spacing: Theme.s2

                        Item {
                            width: Theme.iconMd + Theme.s2; height: Theme.controlH
                            Icon { name: "sun"; size: Theme.iconMd; anchors.centerIn: parent; color: Theme.fg }
                        }

                        FlatSlider {
                            Layout.fillWidth: true
                            value: Services.Brightness.level
                            onMoved: Services.Brightness.set(value)
                        }

                        Text {
                            width: 34
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            text: Math.round(Services.Brightness.level * 100)
                            color: Theme.fg
                            font.pixelSize: Theme.tBody
                            font.family: Theme.fontFamily
                        }
                    }
                }
            }
        }
    }
}