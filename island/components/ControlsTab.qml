import QtQuick
import Quickshell
import "../services" as Services
import qs.components

Item {
    id: root
    anchors.fill: parent
    property bool outputOpen: false
    property bool inputOpen: false

    // Main content area - Flickable for scrolling
    Flickable {
        anchors.fill: parent
        contentWidth: 700
        contentHeight: contentColumn.height
        clip: true

        Column {
            id: contentColumn
            width: 700
            spacing: 16

            // ---- Output card ----
            Card {
                id: outputCard
                width: parent.width
                height: outputDeviceList.y + outputDeviceList.height + 32
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                cardFill: "#141414"
                cardBorderColor: "#3a3a3a"
                cardRadius: 14
                cardPadding: 16

                Item {
                    id: outputContent
                    anchors.fill: parent
                    anchors.margins: 16

                    // header
                    Item {
                        id: outputHeader
                        width: parent.width
                        height: 32
                        anchors.top: parent.top
                        Text {
                            text: "Output"; color: "#ffffff"; font.pixelSize: 12; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        IconButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: "ellipsis-vertical"
                            onClicked: { outputOpen = !outputOpen; inputOpen = false }
                        }
                    }

                    Text {
                        id: outputDeviceName
                        text: Services.Audio.label(Services.Audio.sink)
                        color: "#9a9aa0"; font.pixelSize: 11
                        elide: Text.ElideMiddle
                        anchors.top: outputHeader.bottom; anchors.topMargin: 6
                        anchors.left: parent.left; anchors.right: parent.right
                    }

                    // slider row
                    Item {
                        id: outputSliderRow
                        height: 36
                        anchors.top: outputDeviceName.bottom; anchors.topMargin: 14
                        anchors.left: parent.left; anchors.right: parent.right

                        IconButton {
                            id: outputMuteBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: Services.Audio.sinkMuted ? "volume-x" : "volume-2"
                            active: Services.Audio.sinkMuted
                            onClicked: Services.Audio.toggleSinkMute()
                        }
                        Text {
                            id: pctOut
                            width: 44
                            anchors.right: outputMuteBtn.left; anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(Services.Audio.sinkVolume * 100) + "%"
                            color: "#ffffff"; font.pixelSize: 12; font.bold: true
                        }
                        FlatSlider {
                            id: outputSlider
                            bold: true
                            anchors.left: parent.left
                            anchors.right: pctOut.left; anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            value: Services.Audio.sinkVolume
                            enabled: Services.Audio.sinkReady
                            onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                        }
                    }

                    // DeviceSelector (accordion)
                    DeviceSelector {
                        id: outputDeviceList
                        overlayMode: false
                        width: parent.width
                        model: Services.Audio.sinks
                        currentNode: Services.Audio.sink
                        onPicked: n => Services.Audio.setDefaultSink(n)
                        opened: outputOpen
                        onOpenedChanged: outputOpen = opened
                        anchors.top: outputSliderRow.bottom; anchors.topMargin: 10
                        anchors.left: parent.left; anchors.right: parent.right
                    }
                }
            }

            // ---- Input card ----
            Card {
                id: inputCard
                width: parent.width
                height: inputDeviceList.y + inputDeviceList.height + 32
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                cardFill: "#141414"
                cardBorderColor: "#3a3a3a"
                cardRadius: 14
                cardPadding: 16

                Item {
                    id: inputContent
                    anchors.fill: parent
                    anchors.margins: 16

                    // header
                    Item {
                        id: inputHeader
                        width: parent.width
                        height: 32
                        anchors.top: parent.top
                        Text {
                            text: "Input"; color: "#ffffff"; font.pixelSize: 12; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        IconButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: "ellipsis-vertical"
                            onClicked: { inputOpen = !inputOpen; outputOpen = false }
                        }
                    }

                    Text {
                        id: inputDeviceName
                        text: Services.Audio.label(Services.Audio.source)
                        color: "#9a9aa0"; font.pixelSize: 11
                        elide: Text.ElideMiddle
                        anchors.top: inputHeader.bottom; anchors.topMargin: 6
                        anchors.left: parent.left; anchors.right: parent.right
                    }

                    // slider row
                    Item {
                        id: inputSliderRow
                        height: 36
                        anchors.top: inputDeviceName.bottom; anchors.topMargin: 14
                        anchors.left: parent.left; anchors.right: parent.right

                        IconButton {
                            id: inputMuteBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: Services.Audio.sourceMuted ? "mic-off" : "mic"
                            active: Services.Audio.sourceMuted
                            onClicked: Services.Audio.toggleSourceMute()
                        }
                        FlatSlider {
                            id: inputSlider
                            bold: true
                            anchors.left: parent.left
                            anchors.right: pctIn.left; anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            value: Services.Audio.sourceVolume
                            enabled: Services.Audio.sourceReady
                            onMoved: if (Services.Audio.sourceReady) Services.Audio.setSourceVolume(value)
                        }
                        Text {
                            id: pctIn
                            width: 44
                            anchors.right: inputMuteBtn.left; anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(Services.Audio.sourceVolume * 100) + "%"
                            color: "#ffffff"; font.pixelSize: 12; font.bold: true
                        }
                    }

                    // DeviceSelector (accordion)
                    DeviceSelector {
                        id: inputDeviceList
                        overlayMode: false
                        width: parent.width
                        model: Services.Audio.sources
                        currentNode: Services.Audio.source
                        onPicked: n => Services.Audio.setDefaultSource(n)
                        opened: inputOpen
                        onOpenedChanged: inputOpen = opened
                        anchors.top: inputSliderRow.bottom; anchors.topMargin: 10
                        anchors.left: parent.left; anchors.right: parent.right
                    }
                }
            }

            // ---- Application Volumes card ----
            Card {
                id: appCard
                width: parent.width
                height: 300
                cardFill: "#141414"
                cardBorderColor: "#3a3a3a"
                cardRadius: 14
                cardPadding: 16

                Item {
                    id: appContent
                    anchors.fill: parent
                    anchors.margins: 16

                    Text {
                        id: appTitle
                        text: "Application Volumes"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                        anchors.top: parent.top
                    }

                    ListView {
                        id: appListView
                        anchors.top: appTitle.bottom; anchors.topMargin: 10
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: parent.width
                        clip: true
                        spacing: 8
                        model: Services.Audio.appStreams
                        delegate: Item {
                            id: appRow
                            property bool pickerOpen: false
                            width: ListView.view.width
                            height: pickerOpen ? 84 + Services.Audio.sinks.length * 30 + 8 : 84
                            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            clip: true

                            Rectangle {
                                anchors.fill: parent; anchors.margins: 2
                                color: "#0a0a0a"; radius: 12
                                border.color: "#2a2a2a"; border.width: 1
                            }

                            // app icon / letter fallback
                            Item {
                                x: 14; y: 12; width: 28; height: 28
                                Image {
                                    id: appIcon
                                    anchors.fill: parent
                                    sourceSize: Qt.size(56, 56)
                                    asynchronous: true
                                    source: Quickshell.iconPath(Services.Audio.appIconName(modelData), "app-window")
                                    opacity: modelData.audio && modelData.audio.muted ? 0.4 : 1
                                }
                                Rectangle {
                                    anchors.fill: parent; radius: 14; color: "#2a2a2e"
                                    visible: appIcon.status === Image.Error || appIcon.source === ""
                                    Text {
                                        anchors.centerIn: parent
                                        text: Services.Audio.appName(modelData).charAt(0).toUpperCase()
                                        color: "#ffffff"; font.pixelSize: 14; font.bold: true
                                    }
                                }
                            }

                            // name + detail
                            Column {
                                x: 52; y: 10
                                width: appRow.width - 52 - 100
                                spacing: 2
                                Text {
                                    width: parent.width
                                    text: Services.Audio.appName(modelData)
                                    color: "#ffffff"; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width
                                    text: Services.Audio.appDetail(modelData)
                                    color: "#9a9aa0"; font.pixelSize: 10; elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }

                            // buttons (top right)
                            IconButton {
                                id: appMuteBtn
                                width: 32; height: 32
                                x: appRow.width - width - 12; y: 8
                                iconName: modelData.audio && modelData.audio.muted ? "volume-x" : "volume-2"
                                active: !!(modelData.audio && modelData.audio.muted)
                                onClicked: Services.Audio.toggleNodeMute(modelData)
                            }
                            IconButton {
                                id: appOutBtn
                                width: 32; height: 32
                                x: appMuteBtn.x - width - 6; y: 8
                                iconName: "headphones"
                                active: appRow.pickerOpen
                                onClicked: appRow.pickerOpen = !appRow.pickerOpen
                            }

                            // volume slider row
                            Item {
                                id: appSliderRow
                                x: 52; y: 48
                                width: appRow.width - 52 - 14
                                height: 28

                                Text {
                                    id: appPct
                                    width: 44
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    horizontalAlignment: Text.AlignRight
                                    text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : "0%"
                                    color: "#ffffff"; font.pixelSize: 11; font.bold: true
                                }
                                FlatSlider {
                                    bold: true
                                    anchors.left: parent.left
                                    anchors.right: appPct.left; anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    value: modelData.audio ? modelData.audio.volume : 0
                                    enabled: modelData.audio !== null
                                    onMoved: Services.Audio.setNodeVolume(modelData, value)
                                }
                            }

                            // per-app output picker
                            Column {
                                x: 14; y: 84
                                width: appRow.width - 28
                                spacing: 2
                                visible: appRow.pickerOpen
                                Repeater {
                                    model: Services.Audio.sinks
                                    delegate: Rectangle {
                                        width: parent.width; height: 28; radius: 8
                                        color: sinkMouse.containsMouse ? "#2a2a2e" : "#1a1a1a"
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: 10; width: parent.width - 20
                                            text: Services.Audio.label(modelData)
                                            color: "#ffffff"; font.pixelSize: 11; elide: Text.ElideRight
                                        }
                                        MouseArea {
                                            id: sinkMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                Quickshell.execDetached(["pactl", "move-sink-input",
                                                    String(appStream.id), modelData.name])
                                                appRow.pickerOpen = false
                                            }
                                        }
                                    }
                                }
                            }

                            property var appStream: modelData
                        }
                    }

                    Text {
                        id: appEmptyState
                        anchors.centerIn: parent
                        visible: appListView.count === 0
                        text: "No apps are playing audio"
                        color: "#9a9aa0"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
