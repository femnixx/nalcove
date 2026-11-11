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
                            width: ListView.view.width
                            height: 56

                            Rectangle {
                                id: rowBg
                                anchors.fill: parent
                                anchors.margins: 6
                                color: "#0a0a0a"
                                radius: 12
                                border.color: "#2a2a2a"
                                border.width: 1
                            }

                            Item {
                                id: appIconContainer
                                x: 18; y: 14
                                width: 28; height: 28

                                Image {
                                    id: appIcon
                                    anchors.fill: parent
                                    sourceSize: Qt.size(56, 56)
                                    asynchronous: true
                                    source: Quickshell.iconPath(Services.Audio.appIconName(modelData), "app-window")
                                    opacity: modelData.audio && modelData.audio.muted ? 0.4 : 1
                                }

                                Rectangle {
                                    id: letterAvatar
                                    anchors.fill: parent
                                    radius: 14
                                    color: "#2a2a2e"
                                    visible: appIcon.status === Image.Error || appIcon.source === ""
                                    Text {
                                        anchors.centerIn: parent
                                        text: Services.Audio.appName(modelData).charAt(0).toUpperCase()
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleNodeMute(modelData) }
                            }

                            Column {
                                x: 56; y: 12
                                width: 180
                                spacing: 2
                                Text {
                                    width: parent.width
                                    text: Services.Audio.appName(modelData)
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width
                                    text: Services.Audio.appDetail(modelData)
                                    color: "#9a9aa0"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }

                            FlatSlider {
                                x: 56; y: 36
                                width: ListView.view.width - 56 - 120
                                bold: true
                                value: modelData.audio ? modelData.audio.volume : 0
                                enabled: modelData.audio !== null
                                onMoved: Services.Audio.setNodeVolume(modelData, value)
                            }

                            Text {
                                id: appPct
                                x: ListView.view.width - 54
                                y: 14
                                width: 44
                                text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : "0%"
                                color: "#ffffff"; font.pixelSize: 11; font.bold: true
                                horizontalAlignment: Text.AlignRight
                            }

                            IconButton {
                                id: appHeadphonesBtn
                                x: ListView.view.width - 44; y: 30
                                width: 36; height: 36
                                iconName: "headphones"
                                visible: false
                            }

                            IconButton {
                                id: appMuteBtn
                                x: ListView.view.width - 44; y: 30
                                width: 36; height: 36
                                iconName: modelData.audio && modelData.audio.muted ? "volume-x" : "volume-2"
                                active: !! (modelData.audio && modelData.audio.muted)
                                onClicked: Services.Audio.toggleNodeMute(modelData)
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {}
                            }
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
