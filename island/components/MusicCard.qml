import QtQuick
import Quickshell.Widgets
import "../services"
import "../components"

// Compact Alcove-style music card (Home tab)
Rectangle {
    id: root
    color: Style.card
    radius: Style.cardRadius
    clip: true

    readonly property int art: Math.min(72, Math.round(height * 0.32))

    ClippingRectangle {
        id: artBox
        x: 14; y: 14
        width: root.art; height: root.art
        radius: 12
        color: "#222222"
        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize: Qt.size(160, 160)
        }
    }

    Column {
        x: artBox.x + artBox.width + 12
        y: 16
        width: root.width - x - 14
        spacing: 3
        Text {
            width: parent.width
            text: Media.hasPlayer && Media.title !== "" ? Media.title : "Nothing playing"
            color: Style.fg
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: Media.artist
            color: Style.dim
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 24
        visible: Media.hasPlayer

        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 14; height: 14; kind: "prev"; color: Style.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.previous() }
        }
        Rectangle {
            width: 36; height: 36; radius: 18
            color: "transparent"
            border.color: Style.fg
            border.width: 2
            Glyph {
                anchors.centerIn: parent
                width: 14; height: 14
                kind: Media.isPlaying ? "pause" : "play"
                color: Style.fg
            }
            MouseArea { anchors.fill: parent; onClicked: Media.togglePlay() }
        }
        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 14; height: 14; kind: "next"; color: Style.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.next() }
        }
    }
}