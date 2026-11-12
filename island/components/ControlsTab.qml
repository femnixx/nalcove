import QtQuick
import Quickshell
import "../services" as Services
import qs.components

Item {
    id: root
    property real ui: 1
    anchors.fill: parent
    property bool outputOpen: false
    property bool inputOpen: false

    function s(px) { return Math.round(px * ui) }

    // Main content area - Flickable for scrolling
    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentColumn.height
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: s(16)

            // ---- Output card ----
            Card {
                id: outputCard
                ui: root.ui
                width: parent.width
                height: outputDeviceList.y + outputDeviceList.height + s(32)
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                cardFill: "#141414"
                cardBorderColor: "#3a3a3a"
                cardRadius: 14
                cardPadding: 16

                Item {
                    id: outputContent
                    anchors.fill: parent
                    anchors.margins: s(16)

                    // header
                    Item {
                        id: outputHeader
                        width: parent.width
                        height: s(32)
                        anchors.top: parent.top
                        Text {
                            text: "Output"; color: "#ffffff"; font.pixelSize: 12 * ui; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        IconButton {
                            ui: root.ui
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: "ellipsis-vertical"
                            onClicked: { outputOpen = !outputOpen; inputOpen = false }
                        }
                    }

                    Text {
                        id: outputDeviceName
                        text: Services.Audio.label(Services.Audio.sink)
                        color: "#9a9aa0"; font.pixelSize: 11 * ui
                        elide: Text.ElideMiddle
                        anchors.top: outputHeader.bottom; anchors.topMargin: s(6)
                        anchors.left: parent.left; anchors.right: parent.right
                    }

                    // slider row
                    Item {
                        id: outputSliderRow
                        height: s(36)
                        anchors.top: outputDeviceName.bottom; anchors.topMargin: s(14)
                        anchors.left: parent.left; anchors.right: parent.right

                        IconButton {
                            ui: root.ui
                            id: outputMuteBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: Services.Audio.sinkMuted ? "volume-x" : "volume-2"
                            active: Services.Audio.sinkMuted
                            onClicked: Services.Audio.toggleSinkMute()
                        }
                        Text {
                            id: pctOut
                            width: s(44)
                            anchors.right: outputMuteBtn.left; anchors.rightMargin: s(8)
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(Services.Audio.sinkVolume * 100) + "%"
                            color: "#ffffff"; font.pixelSize: 12 * ui; font.bold: true
                        }
                        FlatSlider {
                            ui: root.ui
                            id: outputSlider
                            bold: true
                            anchors.left: parent.left
                            anchors.right: pctOut.left; anchors.rightMargin: s(8)
                            anchors.verticalCenter: parent.verticalCenter
                            value: Services.Audio.sinkVolume
                            enabled: Services.Audio.sinkReady
                            onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                        }
                    }

                    // DeviceSelector (accordion)
                    DeviceSelector {
                        ui: root.ui
                        id: outputDeviceList
                        overlayMode: false
                        width: parent.width
                        model: Services.Audio.sinks
                        currentNode: Services.Audio.sink
                        onPicked: n => Services.Audio.setDefaultSink(n)
                        opened: outputOpen
                        onOpenedChanged: outputOpen = opened
                        anchors.top: outputSliderRow.bottom; anchors.topMargin: s(10)
                        anchors.left: parent.left; anchors.right: parent.right
                    }
                }
            }

            // ---- Input card ----
            Card {
                ui: root.ui
                id: inputCard
                width: parent.width
                height: inputDeviceList.y + inputDeviceList.height + s(32)
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                cardFill: "#141414"
                cardBorderColor: "#3a3a3a"
                cardRadius: 14
                cardPadding: 16

                Item {
                    id: inputContent
                    anchors.fill: parent
                    anchors.margins: s(16)

                    // header
                    Item {
                        id: inputHeader
                        width: parent.width
                        height: s(32)
                        anchors.top: parent.top
                        Text {
                            text: "Input"; color: "#ffffff"; font.pixelSize: 12 * ui; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        IconButton {
                            ui: root.ui
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: "ellipsis-vertical"
                            onClicked: { inputOpen = !inputOpen; outputOpen = false }
                        }
                    }

                    Text {
                        id: inputDeviceName
                        text: Services.Audio.label(Services.Audio.source)
                        color: "#9a9aa0"; font.pixelSize: 11 * ui
                        elide: Text.ElideMiddle
                        anchors.top: inputHeader.bottom; anchors.topMargin: s(6)
                        anchors.left: parent.left; anchors.right: parent.right
                    }

                    // slider row
                    Item {
                        id: inputSliderRow
                        height: s(36)
                        anchors.top: inputDeviceName.bottom; anchors.topMargin: s(14)
                        anchors.left: parent.left; anchors.right: parent.right

                        IconButton {
                            ui: root.ui
                            id: inputMuteBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: Services.Audio.sourceMuted ? "mic-off" : "mic"
                            active: Services.Audio.sourceMuted
                            onClicked: Services.Audio.toggleSourceMute()
                        }
                        FlatSlider {
                            ui: root.ui
                            id: inputSlider
                            bold: true
                            anchors.left: parent.left
                            anchors.right: pctIn.left; anchors.rightMargin: s(8)
                            anchors.verticalCenter: parent.verticalCenter
                            value: Services.Audio.sourceVolume
                            enabled: Services.Audio.sourceReady
                            onMoved: if (Services.Audio.sourceReady) Services.Audio.setSourceVolume(value)
                        }
                        Text {
                            id: pctIn
                            width: s(44)
                            anchors.right: inputMuteBtn.left; anchors.rightMargin: s(8)
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            text: Math.round(Services.Audio.sourceVolume * 100) + "%"
                            color: "#ffffff"; font.pixelSize: 12 * ui; font.bold: true
                        }
                    }

                    // DeviceSelector (accordion)
                    DeviceSelector {
                        ui: root.ui
                        id: inputDeviceList
                        overlayMode: false
                        width: parent.width
                        model: Services.Audio.sources
                        currentNode: Services.Audio.source
                        onPicked: n => Services.Audio.setDefaultSource(n)
                        opened: inputOpen
                        onOpenedChanged: inputOpen = opened
                        anchors.top: inputSliderRow.bottom; anchors.topMargin: s(10)
                        anchors.left: parent.left; anchors.right: parent.right
                    }
                }
            }

            // ---- Application Volumes card ----
            Card {
                ui: root.ui
                id: appCard
                width: parent.width
                height: s(300)
                cardFill: "#141414"
                cardBorderColor: "#3a3a3a"
                cardRadius: 14
                cardPadding: 16

                Item {
                    id: appContent
                    anchors.fill: parent
                    anchors.margins: s(16)

                    Text {
                        id: appTitle
                        text: "Application Volumes"
                        color: "#ffffff"
                        font.pixelSize: 12 * ui
                        font.bold: true
                        anchors.top: parent.top
                    }

                    ListView {
                        id: appListView
                        anchors.top: appTitle.bottom; anchors.topMargin: s(10)
                        anchors.left: parent.left; anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: parent.width
                        clip: true
                        spacing: s(8)
                        model: Services.Audio.appStreams
                        delegate: Item {
                            id: appRow
                            property bool pickerOpen: false
                            width: ListView.view.width
                            height: pickerOpen ? s(84) + Services.Audio.sinks.length * s(30) + s(8) : s(84)
                            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            clip: true

                            Rectangle {
                                anchors.fill: parent; anchors.margins: s(2)
                                color: "#0a0a0a"; radius: s(12)
                                border.color: "#2a2a2a"; border.width: s(1)
                            }

                            // app icon / letter fallback
                            Item {
                                x: s(14); y: s(12); width: s(28); height: s(28)
                                Image {
                                    id: appIcon
                                    anchors.fill: parent
                                    sourceSize: Qt.size(s(56), s(56))
                                    asynchronous: true
                                    source: Quickshell.iconPath(Services.Audio.appIconName(modelData), "app-window")
                                    opacity: modelData.audio && modelData.audio.muted ? 0.4 : 1
                                }
                                Rectangle {
                                    anchors.fill: parent; radius: s(14); color: "#2a2a2e"
                                    visible: appIcon.status === Image.Error || appIcon.source === ""
                                    Text {
                                        anchors.centerIn: parent
                                        text: Services.Audio.appName(modelData).charAt(0).toUpperCase()
                                        color: "#ffffff"; font.pixelSize: 14 * ui; font.bold: true
                                    }
                                }
                            }

                            // name + detail
                            Column {
                                x: s(52); y: s(10)
                                width: appRow.width - s(52) - s(100)
                                spacing: s(2)
                                Text {
                                    width: parent.width
                                    text: Services.Audio.appName(modelData)
                                    color: "#ffffff"; font.pixelSize: 12 * ui; font.bold: true; elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width
                                    text: Services.Audio.appDetail(modelData)
                                    color: "#9a9aa0"; font.pixelSize: 10 * ui; elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }

                            // buttons (top right)
                            IconButton {
                                ui: root.ui
                                id: appMuteBtn
                                width: s(32); height: s(32)
                                x: appRow.width - width - s(12); y: s(8)
                                iconName: modelData.audio && modelData.audio.muted ? "volume-x" : "volume-2"
                                active: !!(modelData.audio && modelData.audio.muted)
                                onClicked: Services.Audio.toggleNodeMute(modelData)
                            }
                            IconButton {
                                ui: root.ui
                                id: appOutBtn
                                width: s(32); height: s(32)
                                x: appMuteBtn.x - width - s(6); y: s(8)
                                iconName: "headphones"
                                active: appRow.pickerOpen
                                onClicked: appRow.pickerOpen = !appRow.pickerOpen
                            }

                            // volume slider row
                            Item {
                                id: appSliderRow
                                x: s(52); y: s(48)
                                width: appRow.width - s(52) - s(14)
                                height: s(28)

                                Text {
                                    id: appPct
                                    width: s(44)
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    horizontalAlignment: Text.AlignRight
                                    text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : "0%"
                                    color: "#ffffff"; font.pixelSize: 11 * ui; font.bold: true
                                }
                                FlatSlider {
                                    ui: root.ui
                                    bold: true
                                    anchors.left: parent.left
                                    anchors.right: appPct.left; anchors.rightMargin: s(8)
                                    anchors.verticalCenter: parent.verticalCenter
                                    value: modelData.audio ? modelData.audio.volume : 0
                                    enabled: modelData.audio !== null
                                    onMoved: Services.Audio.setNodeVolume(modelData, value)
                                }
                            }

                            // per-app output picker
                            Column {
                                x: s(14); y: s(84)
                                width: appRow.width - s(28)
                                spacing: s(2)
                                visible: appRow.pickerOpen
                                Repeater {
                                    model: Services.Audio.sinks
                                    delegate: Rectangle {
                                        width: parent.width; height: s(28); radius: s(8)
                                        color: sinkMouse.containsMouse ? "#2a2a2e" : "#1a1a1a"
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: s(10); width: parent.width - s(20)
                                            text: Services.Audio.label(modelData)
                                            color: "#ffffff"; font.pixelSize: 11 * ui; elide: Text.ElideRight
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
                        font.pixelSize: 12 * ui
                    }
                }
            }
        }
    }
}
