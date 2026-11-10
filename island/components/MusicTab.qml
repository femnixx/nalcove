import QtQuick
import QtQuick.Controls
import "../services" as Services

Item {
    id: tab

    function fmtTime(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    Component.onCompleted: Services.Lyrics.users = Services.Lyrics.users + 1
    Component.onDestruction: Services.Lyrics.users = Services.Lyrics.users - 1

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 20

        Item {
            width: parent.width - 290 - parent.spacing
            height: parent.height

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Row {
                    width: parent.width; height: 110; spacing: 16
                    Rectangle {
                        width: 110; height: 110; radius: 14; color: "#2c2c2e"; clip: true
                        Image {
                            id: art
                            anchors.fill: parent; fillMode: Image.PreserveAspectCrop
                            source: Services.Media.artUrl
                            asynchronous: true; cache: true
                            sourceSize: Qt.size(220, 220)
                        }
                        Icon { name: "media-playlist-normal"; size: 32; anchors.centerIn: parent; color: "#ffffff"
                               visible: art.status !== Image.Ready }
                    }
                    Column {
                        width: parent.width - 126; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                        Text { width: parent.width; elide: Text.ElideRight; color: "#ffffff"; font.pixelSize: 16; font.bold: true
                               text: Services.Media.hasPlayer ? Services.Media.title : "Nothing playing" }
                        Text { width: parent.width; elide: Text.ElideRight; color: "#9a9aa0"; font.pixelSize: 13
                               text: Services.Media.artist !== "" ? Services.Media.artist : "Start playing a track\u2026" }
                    }
                }

                Row {
                    width: parent.width; height: 44
                    spacing: (parent.width - (24 + 24 + 40 + 24 + 24)) / 4

                    Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "shuffle"; size: 20; anchors.centerIn: parent
                               color: Services.Media.shuffleOn ? "#3b8bff" : "#9a9aa0" }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleShuffle() } }
                    Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "media-skip-backward"; size: 24; color: "#9a9aa0"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.previous() } }
                    Item { width: 40; height: 40; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: Services.Media.isPlaying ? "pause" : "play"; size: 32; color: "#ffffff"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.togglePlay() } }
                    Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "media-skip-forward"; size: 24; color: "#9a9aa0"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.next() } }
                    Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "repeat"; size: 20; anchors.centerIn: parent
                               color: Services.Media.repeatOn ? "#3b8bff" : "#9a9aa0" }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleRepeat() } }
                }

                Column {
                    width: parent.width; height: 40; spacing: 6
                    Slider {
                        id: progress
                        width: parent.width; height: 14
                        value: Services.Media.length > 0 ? Services.Media.position / Services.Media.length : 0
                        background: Rectangle {
                            height: 5; radius: 3; color: "#22ffffff"
                            Rectangle { width: progress.visualPosition * parent.width; height: 5; color: "#ffffff"; radius: 3 }
                        }
                        handle: Rectangle {
                            x: progress.visualPosition * (progress.width - width); y: -5
                            width: 14; height: 14; radius: 7; color: "#ffffff"
                        }
                        onMoved: if (Services.Media.length > 0) Services.Media.seek(value * Services.Media.length)
                    }
                    Item {
                        width: parent.width; height: 14
                        Text { text: tab.fmtTime(Services.Media.position); color: "#66ffffff"; font.pixelSize: 11 }
                        Text { anchors.right: parent.right; color: "#66ffffff"; font.pixelSize: 11
                               text: Services.Media.length > 0 ? tab.fmtTime(Services.Media.length) : "0:00" }
                    }
                }

                Row {
                    width: parent.width; height: 24; spacing: 12
                    Icon { name: "volume"; size: 16; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter
                           opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }
                    FlatSlider {
                        width: parent.width - 16 - 34 - 24
                        anchors.verticalCenter: parent.verticalCenter
                        value: Services.Audio.sinkVolume
                        enabled: Services.Audio.sinkReady
                        onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                    }
                    Text { width: 34; anchors.verticalCenter: parent.verticalCenter
                           horizontalAlignment: Text.AlignRight; color: "#ffffff"; font.pixelSize: 12
                           text: Math.round(Services.Audio.sinkVolume * 100) }
                }
            }
        }

        Rectangle {
            width: 290
            height: parent.height
            radius: 18
            color: "#16ffffff"
            border.color: Style.cardBorder
            border.width: 1
            clip: true

            LyricsPanel { anchors.fill: parent; anchors.margins: 14 }
        }
    }
}