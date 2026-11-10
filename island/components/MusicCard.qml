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

    readonly property int art: Math.min(150, Math.round(height * 0.55))

    ClippingRectangle {
        id: artBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: 14
        width: root.art; height: root.art
        radius: 12
        color: "#222222"
        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize: Qt.size(240, 240)
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: artBox.bottom
        anchors.topMargin: 10
        width: root.width - 28
        spacing: 4
        Text {
            width: parent.width
            text: Media.hasPlayer && Media.title !== "" ? Media.title : "Nothing playing"
            color: Style.fg
            font.pixelSize: 14
            font.bold: true
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            width: parent.width
            text: Media.artist
            color: Style.dim
            font.pixelSize: 12
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
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
