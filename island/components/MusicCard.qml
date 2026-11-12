import QtQuick
import Quickshell.Widgets
import "../services"
import "../components"

// Compact Alcove-style music card (Home tab)
Rectangle {
    id: root
    property real ui: 1
    color: Style.card
    radius: Style.cardRadius
    clip: true

    function s(px) { return Math.round(px * ui) }

    readonly property real art: Math.min(s(150), Math.round(height * 0.55))

    ClippingRectangle {
        id: artBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: s(14)
        width: root.art; height: root.art
        radius: s(12)
        color: "#222222"
        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize: Qt.size(s(240), s(240))
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: artBox.bottom
        anchors.topMargin: s(10)
        width: root.width - s(28)
        spacing: s(4)
        Text {
            width: parent.width
            text: Media.hasPlayer && Media.title !== "" ? Media.title : "Nothing playing"
            color: Style.fg
            font.pixelSize: 14 * ui
            font.bold: true
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            width: parent.width
            text: Media.artist
            color: Style.dim
            font.pixelSize: 12 * ui
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: s(16)
        spacing: s(24)
        visible: Media.hasPlayer

        Item {
            width: s(36); height: s(36)
            Glyph { anchors.centerIn: parent; width: s(14); height: s(14); kind: "prev"; color: Style.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.previous() }
        }
        Rectangle {
            width: s(36); height: s(36); radius: s(18)
            color: "transparent"
            border.color: Style.fg
            border.width: s(2)
            Glyph {
                anchors.centerIn: parent
                width: s(14); height: s(14)
                kind: Media.isPlaying ? "pause" : "play"
                color: Style.fg
            }
            MouseArea { anchors.fill: parent; onClicked: Media.togglePlay() }
        }
        Item {
            width: s(36); height: s(36)
            Glyph { anchors.centerIn: parent; width: s(14); height: s(14); kind: "next"; color: Style.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.next() }
        }
    }
}
