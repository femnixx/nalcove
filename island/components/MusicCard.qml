import QtQuick
import Quickshell.Widgets
import "../services"

// Compact Alcove-style music card (used on the Home tab)
Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius

    function fmt(s) {
        const t = Math.max(0, Math.floor(s / 1000000))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    ClippingRectangle {
        x: 14; y: 14
        width: 100; height: 100
        radius: 14
        color: "#222222"
        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    Column {
        x: 126; y: 22
        width: root.width - 126 - 14
        spacing: 4
        Text {
            width: parent.width
            text: Media.hasPlayer ? Media.title : "Nothing playing"
            color: Theme.fg
            font.pixelSize: 14
            font.bold: true
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: Media.artist
            color: Theme.dim
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    Row {
        x: (root.width - width) / 2
        y: 130
        spacing: 28
        visible: Media.hasPlayer

        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 14; height: 14; kind: "prev"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.previous() }
        }
        Rectangle {
            width: 36; height: 36; radius: 18
            color: "transparent"
            border.color: Theme.fg
            border.width: 2
            Glyph {
                anchors.centerIn: parent
                width: 14; height: 14
                kind: Media.isPlaying ? "pause" : "play"
                color: Theme.fg
            }
            MouseArea { anchors.fill: parent; onClicked: Media.playPause() }
        }
        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 14; height: 14; kind: "next"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.next() }
        }
    }
}
