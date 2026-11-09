import QtQuick
import Quickshell.Widgets
import "../services"

// Full music player card
Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    readonly property real rightW: width - 220 - 24

    function fmt(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    // Background accent gradient effect when playing
    Rectangle {
        id: bgGradient
        anchors.fill: parent
        radius: Theme.cardRadius
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        gradient: Gradient {
            GradientStop { position: 0; color: Theme.accentFill }
            GradientStop { position: 1; color: "transparent" }
        }

        Binding {
            target: bgGradient
            property: "opacity"
            value: Media.hasPlayer && Media.isPlaying ? 0.15 : 0
        }
    }

    // Album Art with rounded corners and shadow
    Rectangle {
        x: 24; y: 24
        width: 172; height: 172
        radius: 20
        color: "#1a1a1a"
        border.color: Theme.border
        border.width: 1
        clip: true

        Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Behavior on source { PropertyAnimation { duration: 400 } }
        }

        // Play/Pause overlay on album art when hovered
        MouseArea {
            id: artMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Media.playPause()

            Rectangle {
                anchors.fill: parent
                color: "#00000080"
                radius: 20
                visible: (Media.hasPlayer) && parent.containsMouse
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Glyph {
                    anchors.centerIn: parent
                    width: 48; height: 48
                    kind: Media.isPlaying ? "pause" : "play"
                    color: "white"
                }
            }
        }
    }

    // Track info
    Column {
        x: 220; y: 30
        width: root.rightW
        spacing: 6

        Text {
            width: parent.width
            text: Media.hasPlayer ? Media.title : "Nothing playing"
            color: Theme.fg
            font.pixelSize: 22
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: Media.artist
            color: Theme.dim
            font.pixelSize: 15
            elide: Text.ElideRight
        }

        // Album name if available
        Text {
            width: parent.width
            text: Media.album || ""
            color: Theme.dim
            font.pixelSize: 12
            elide: Text.ElideRight
            visible: Media.hasPlayer && Media.album
        }
    }

    // Progress bar with time labels
    Item {
        x: 220; y: 112
        width: root.rightW; height: 28
        visible: Media.hasPlayer

        Row {
            anchors.fill: parent
            spacing: 10

            Text {
                text: root.fmt(Media.position)
                color: Theme.dim
                font.pixelSize: 11
                width: 45
            }

            Item {
                width: parent.width - 90 - 45; height: 4
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: Theme.track
                }
                Rectangle {
                    y: 0; height: 4; radius: 2
                    color: Theme.accent
                    width: Media.length > 0 ? (parent.width - 2) * Math.min(1, Media.position / Media.length) : 0
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: (mouse) => { if (Media.length > 0) Media.seek(mouse.x / width * Media.length) }
                    onPositionChanged: (mouse) => { if (pressed && Media.length > 0) Media.seek(mouse.x / width * Media.length) }
                }
            }

            Text {
                text: root.fmt(Media.length)
                color: Theme.dim
                font.pixelSize: 11
                width: 45
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    // Control buttons centered
    Row {
        x: 220 + (root.rightW - width) / 2
        y: 150
        spacing: 28
        visible: Media.hasPlayer

        // Shuffle
        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 16; height: 16; kind: "shuffle"; color: Theme.dim }
            MouseArea { anchors.fill: parent; onClicked: Media.shuffle() }
        }

        // Previous
        Item {
            width: 44; height: 44
            Glyph { anchors.centerIn: parent; width: 20; height: 20; kind: "prev"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.previous() }
        }

        // Play/Pause - prominent button
        Rectangle {
            width: 52; height: 52; radius: 26
            color: Theme.accent
            border.color: "transparent"
            border.width: 0
            Glyph {
                anchors.centerIn: parent
                width: 20; height: 20
                kind: Media.isPlaying ? "pause" : "play"
                color: "white"
            }
            MouseArea {
                id: playMouseArea
                anchors.fill: parent
                onClicked: Media.playPause()
            }
            scale: playMouseArea.pressed ? 0.95 : 1
            Behavior on scale { SpringAnimation { spring: 2; damping: 0.3 } }
        }

        // Next
        Item {
            width: 44; height: 44
            Glyph { anchors.centerIn: parent; width: 20; height: 20; kind: "next"; color: Theme.fg }
            MouseArea { anchors.fill: parent; onClicked: Media.next() }
        }

        // Repeat
        Item {
            width: 36; height: 36
            Glyph { anchors.centerIn: parent; width: 16; height: 16; kind: "repeat"; color: Theme.dim }
            MouseArea { anchors.fill: parent; onClicked: Media.repeat() }
        }
    }

    // Volume slider below controls
    Item {
        x: 220; y: 210
        width: root.rightW; height: 36
        visible: Media.hasPlayer

        Row {
            anchors.fill: parent
            spacing: 10
            Glyph { anchors.verticalCenter: parent.verticalCenter; width: 16; height: 16; kind: "volume"; color: Theme.dim }

            Item {
                width: parent.width - 60; height: 4
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: Theme.track
                }
                Rectangle {
                    y: 0; height: 4; radius: 2
                    color: Theme.accent
                    width: (parent.width - 2) * Media.volume
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: (mouse) => { Media.setVolume(mouse.x / width) }
                    onPositionChanged: (mouse) => { if (pressed) Media.setVolume(mouse.x / width) }
                }
            }

            Glyph { anchors.verticalCenter: parent.verticalCenter; width: 16; height: 16; kind: "volume"; color: Theme.dim }
        }
    }
}
