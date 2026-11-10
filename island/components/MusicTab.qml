import QtQuick
import qs.components 1.0
import QtQuick.Controls
import QtQuick.Layouts
import "../services" as Services


Item {
    id: tab

    function fmtTime(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    Component.onCompleted: Services.Lyrics.users = Services.Lyrics.users + 1
    Component.onDestruction: Services.Lyrics.users = Services.Lyrics.users - 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s4

        // ---------- LEFT: player ----------
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 300

            Column {
                anchors.fill: parent
                spacing: Theme.s3

                // Artwork + title/artist
                Row {
                    Layout.fillWidth: true
                    height: 110
                    spacing: Theme.s3

                    Rectangle {
                        width: 110; height: 110
                        radius: Theme.rMd
                        color: Theme.cardHi
                        clip: true

                        Image {
                            id: art
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: Services.Media.artUrl
                            asynchronous: true
                            cache: true
                            sourceSize: Qt.size(220, 220)
                        }
                        Icon { name: "media-playlist-normal"; size: Theme.iconLg; anchors.centerIn: parent; color: Theme.fg
                               visible: art.status !== Image.Ready }
                    }

                    Column {
                        Layout.fillWidth: true
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.s1

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            color: Theme.fg
                            font.pixelSize: Theme.tTitle
                            font.bold: true
                            font.family: Theme.fontFamily
                            text: Services.Media.hasPlayer ? Services.Media.title : "Nothing playing"
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            color: Theme.dim
                            font.pixelSize: Theme.tBody
                            font.family: Theme.fontFamily
                            text: Services.Media.artist !== "" ? Services.Media.artist : "Start playing a track\u2026"
                        }
                    }
                }

                // Transport controls
                Row {
                    Layout.fillWidth: true
                    height: Theme.controlH + 8
                    spacing: 0

                    Item { Layout.fillWidth: true }

                    Item {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "shuffle"; size: Theme.iconMd; anchors.centerIn: parent
                               color: Services.Media.shuffleOn ? Theme.accent : Theme.dim }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleShuffle() }
                    }

                    Item {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "media-skip-backward"; size: Theme.iconLg; color: Theme.dim; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.previous() }
                    }

                    Item {
                        width: Theme.controlH + 8; height: Theme.controlH + 8
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            anchors.centerIn: parent
                            width: Theme.controlH; height: Theme.controlH
                            radius: Theme.controlH / 2
                            color: Theme.accent
                            Icon {
                                anchors.centerIn: parent
                                name: Services.Media.isPlaying ? "pause" : "play"
                                size: Theme.iconLg
                                color: "#ffffff"
                            }
                            MouseArea { anchors.fill: parent; onClicked: Services.Media.togglePlay() }
                        }
                    }

                    Item {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "media-skip-forward"; size: Theme.iconLg; color: Theme.dim; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.next() }
                    }

                    Item {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "repeat"; size: Theme.iconMd; anchors.centerIn: parent
                               color: Services.Media.repeatOn ? Theme.accent : Theme.dim }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleRepeat() }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Progress
                Column {
                    Layout.fillWidth: true
                    height: 40
                    spacing: Theme.s1

                    Slider {
                        id: progress
                        width: parent.width
                        height: 14
                        value: Services.Media.length > 0 ? Services.Media.position / Services.Media.length : 0
                        background: Rectangle {
                            height: 5; radius: 3; color: Theme.track
                            Rectangle { width: progress.visualPosition * parent.width; height: 5; color: Theme.fg; radius: 3 }
                        }
                        handle: Rectangle {
                            x: progress.visualPosition * (progress.width - width); y: -5
                            width: 14; height: 14; radius: 7; color: Theme.fg
                        }
                        onMoved: if (Services.Media.length > 0) Services.Media.seek(value * Services.Media.length)
                    }
                    Row {
                        width: parent.width; height: 14
                        Text { text: tab.fmtTime(Services.Media.position); color: Theme.faint; font.pixelSize: Theme.tCaption; font.family: Theme.fontFamily }
                        Text { anchors.right: parent.right; color: Theme.faint; font.pixelSize: Theme.tCaption; font.family: Theme.fontFamily
                               text: Services.Media.length > 0 ? tab.fmtTime(Services.Media.length) : "0:00" }
                    }
                }

                // Volume
                Row {
                    Layout.fillWidth: true
                    height: Theme.controlH
                    spacing: Theme.s2

                    Icon { name: "volume"; size: Theme.iconMd; color: Theme.fg; anchors.verticalCenter: parent.verticalCenter
                           opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }

                    FlatSlider {
                        Layout.fillWidth: true
                        anchors.verticalCenter: parent.verticalCenter
                        value: Services.Audio.sinkVolume
                        enabled: Services.Audio.sinkReady
                        onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                    }

                    Text {
                        width: 34
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        color: Theme.fg
                        font.pixelSize: Theme.tBody
                        font.family: Theme.fontFamily
                        text: Math.round(Services.Audio.sinkVolume * 100)
                    }
                }
            }
        }

        // ---------- RIGHT: lyrics card ----------
        Rectangle {
            width: 290
            Layout.fillHeight: true
            Layout.minimumWidth: 290
            Layout.maximumWidth: 290
            radius: Theme.rLg
            color: Theme.card
            border.color: Theme.cardBorder
            border.width: 1
            clip: true

            LyricsPanel { anchors.fill: parent; anchors.margins: Theme.s3 }
        }
    }
}