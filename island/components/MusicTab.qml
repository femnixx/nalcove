import QtQuick
import QtQuick.Controls
import "../services" as Services

Item {
    id: tab
    property real ui: 1

    function s(px) { return Math.round(px * ui) }

    function fmtTime(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    Component.onCompleted: Services.Lyrics.users = Services.Lyrics.users + 1
    Component.onDestruction: Services.Lyrics.users = Services.Lyrics.users - 1

    Row {
        anchors.fill: parent
        anchors.margins: s(8)
        spacing: s(20)

        Item {
            width: parent.width - s(290) - parent.spacing
            height: parent.height

            Column {
                anchors.fill: parent
                anchors.margins: s(12)
                spacing: s(8)

                Row {
                    width: parent.width; height: s(110); spacing: s(16)
                    Rectangle {
                        width: s(110); height: s(110); radius: s(14); color: "#2c2c2e"; clip: true
                        Image {
                            id: art
                            anchors.fill: parent; fillMode: Image.PreserveAspectCrop
                            source: Services.Media.artUrl
                            asynchronous: true; cache: true
                            sourceSize: Qt.size(s(220), s(220))
                        }
                        Icon { name: "media-playlist-normal"; size: s(32); anchors.centerIn: parent; color: "#ffffff"
                               visible: art.status !== Image.Ready }
                    }
                    Column {
                        width: parent.width - s(126); anchors.verticalCenter: parent.verticalCenter; spacing: s(4)
                        Text { width: parent.width; elide: Text.ElideRight; color: "#ffffff"; font.pixelSize: 16 * ui; font.bold: true
                               text: Services.Media.hasPlayer ? Services.Media.title : "Nothing playing" }
                        Text { width: parent.width; elide: Text.ElideRight; color: "#9a9aa0"; font.pixelSize: 13 * ui
                               text: Services.Media.artist !== "" ? Services.Media.artist : "Start playing a track\u2026" }
                    }
                }

                Row {
                    width: parent.width; height: s(44)
                    spacing: (parent.width - (s(24) + s(24) + s(40) + s(24) + s(24))) / 4

                    Item { width: s(24); height: s(24); anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "shuffle"; size: s(20); anchors.centerIn: parent
                               color: Services.Media.shuffleOn ? "#3b8bff" : "#9a9aa0" }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleShuffle() } }
                    Item { width: s(24); height: s(24); anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "media-skip-backward"; size: s(24); color: "#9a9aa0"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.previous() } }
                    Item { width: s(40); height: s(40); anchors.verticalCenter: parent.verticalCenter
                        Icon { name: Services.Media.isPlaying ? "pause" : "play"; size: s(32); color: "#ffffff"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.togglePlay() } }
                    Item { width: s(24); height: s(24); anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "media-skip-forward"; size: s(24); color: "#9a9aa0"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.next() } }
                    Item { width: s(24); height: s(24); anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "repeat"; size: s(20); anchors.centerIn: parent
                               color: Services.Media.repeatOn ? "#3b8bff" : "#9a9aa0" }
                        MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleRepeat() } }
                }

                Column {
                    width: parent.width; height: s(40); spacing: s(6)
                    Slider {
                        id: progress
                        width: parent.width; height: s(14)
                        value: Services.Media.length > 0 ? Services.Media.position / Services.Media.length : 0
                        background: Rectangle {
                            height: s(5); radius: s(3); color: "#22ffffff"
                            Rectangle { width: progress.visualPosition * parent.width; height: s(5); color: "#ffffff"; radius: s(3) }
                        }
                        handle: Rectangle {
                            x: progress.visualPosition * (progress.width - s(14)); y: -s(5)
                            width: s(14); height: s(14); radius: s(7); color: "#ffffff"
                        }
                        onMoved: if (Services.Media.length > 0) Services.Media.seek(value * Services.Media.length)
                    }
                    Item {
                        width: parent.width; height: s(14)
                        Text { text: tab.fmtTime(Services.Media.position); color: "#66ffffff"; font.pixelSize: 11 * ui }
                        Text { anchors.right: parent.right; color: "#66ffffff"; font.pixelSize: 11 * ui
                               text: Services.Media.length > 0 ? tab.fmtTime(Services.Media.length) : "0:00" }
                    }
                }

                Row {
                    width: parent.width; height: s(24); spacing: s(12)
                    Icon { name: "volume"; size: s(16); color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter
                           opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }
                    FlatSlider {
                        ui: root.ui
                        width: parent.width - s(16) - s(34) - s(24)
                        anchors.verticalCenter: parent.verticalCenter
                        value: Services.Audio.sinkVolume
                        enabled: Services.Audio.sinkReady
                        onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                    }
                    Text { width: s(34); anchors.verticalCenter: parent.verticalCenter
                           horizontalAlignment: Text.AlignRight; color: "#ffffff"; font.pixelSize: 12 * ui
                           text: Math.round(Services.Audio.sinkVolume * 100) }
                }
            }
        }

        Rectangle {
            width: s(290)
            height: parent.height
            radius: s(18)
            color: "#16ffffff"
            border.color: Style.cardBorder
            border.width: s(1)
            clip: true

            LyricsPanel { anchors.fill: parent; anchors.margins: s(14) }
        }
    }
}
