import QtQuick
import Quickshell.Widgets
import "../services"
import "../components"


// Compact Alcove-style music card (Home tab)
Card {
    id: root
    hoverEnabled: false

    readonly property int art: Math.min(72, Math.round(height * 0.32))

    ClippingRectangle {
        id: artBox
        x: Theme.s4; y: Theme.s4
        width: root.art; height: root.art
        radius: 12
        color: Theme.cardHi
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
        x: artBox.x + artBox.width + Theme.s3
        y: Theme.s4
        width: root.width - x - Theme.s4
        spacing: Theme.s1
        Text {
            width: parent.width
            text: Media.hasPlayer && Media.title !== "" ? Media.title : "Nothing playing"
            color: Theme.fg
            font.pixelSize: Theme.tBody
            font.bold: true
            font.family: Theme.fontFamily
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: Media.artist
            color: Theme.dim
            font.pixelSize: Theme.tSmall
            font.family: Theme.fontFamily
            elide: Text.ElideRight
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.s4
        spacing: Theme.s3
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
            MouseArea { anchors.fill: parent; onClicked: Media.togglePlay() }
        }
        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 14; height: 14; kind: "next"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.next() }
        }
    }
}