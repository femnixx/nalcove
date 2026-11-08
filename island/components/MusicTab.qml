import QtQuick
import Quickshell.Widgets
import "../services"

// Full music player card
Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    readonly property real rightW: width - 208 - 24

    function fmt(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    ClippingRectangle {
        x: 24; y: 24
        width: 160; height: 160
        radius: 18
        color: "#222222"
        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    Column {
        x: 208; y: 30
        width: root.rightW
        spacing: 4
        Text {
            width: parent.width
            text: Media.hasPlayer ? Media.title : "Nothing playing"
            color: Theme.fg
            font.pixelSize: 20
            font.bold: true
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: Media.artist
            color: Theme.dim
            font.pixelSize: 14
            elide: Text.ElideRight
        }
    }

    Item {
        x: 208; y: 108
        width: root.rightW; height: 14
        visible: Media.hasPlayer
        Rectangle { y: 5; width: parent.width; height: 4; radius: 2; color: Theme.track }
        Rectangle {
            y: 5; height: 4; radius: 2; color: Theme.fg
            width: Media.length > 0 ? parent.width * Math.min(1, Media.position / Media.length) : 0
        }
        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => { if (Media.length > 0) Media.seek(mouse.x / width * Media.length) }
        }
    }

    Text {
        x: 208; y: 126
        visible: Media.hasPlayer
        text: root.fmt(Media.position)
        color: Theme.dim
        font.pixelSize: 11
    }
    Text {
        x: 208 + root.rightW - width; y: 126
        visible: Media.hasPlayer
        text: root.fmt(Media.length)
        color: Theme.dim
        font.pixelSize: 11
    }

    Row {
        x: 208 + (root.rightW - width) / 2
        y: 150
        spacing: 40
        visible: Media.hasPlayer

        Item {
            width: 40; height: 40
            Glyph { anchors.centerIn: parent; width: 18; height: 18; kind: "prev"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.previous() }
        }
        Rectangle {
            width: 40; height: 40; radius: 20
            color: "white"
            Glyph {
                anchors.centerIn: parent
                width: 16; height: 16
                kind: Media.isPlaying ? "pause" : "play"
                color: "black"
            }
            MouseArea { anchors.fill: parent; onClicked: Media.playPause() }
        }
        Item {
            width: 40; height: 40
            Glyph { anchors.centerIn: parent; width: 18; height: 18; kind: "next"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.next() }
        }
    }
}
