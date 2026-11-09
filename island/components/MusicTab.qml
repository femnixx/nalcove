import QtQuick
import Quickshell.Widgets
import "../services"

// Full music player card - redesigned to match reference
Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    readonly property real rightW: width - 220 - 24
    property string musicPage: "playing" // "playing" or "lyrics"

    function fmt(s) {
        // MPRIS position is in microseconds, convert to seconds
        const t = Math.max(0, Math.floor(s / 1000000))
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

    // Album Art on left
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

    // ============================================================
    // RIGHT PANEL - CLEAN VERTICAL STACK LAYOUT (REFERENCE DESIGN)
    // ============================================================
    Column {
        x: 220
        y: 24
        width: root.rightW
        spacing: 16
        anchors.rightMargin: 24
        visible: Media.hasPlayer && root.musicPage === "playing"

        // --- SECTION 1: TAB TOGGLES (PLAYING VS LYRICS) ---
        Row {
            width: parent.width
            height: 32
            spacing: 8

            Rectangle {
                width: (parent.width - 8) / 2; height: 32; radius: 8
                color: root.musicPage === "playing" ? Theme.accent : Theme.cardHi
                border.color: root.musicPage === "playing" ? "transparent" : Theme.border
                border.width: 1
                Text { text: "Playing"; color: root.musicPage === "playing" ? "white" : Theme.fg; font.bold: true; font.pixelSize: 12; anchors.centerIn: parent }
                MouseArea { anchors.fill: parent; onClicked: root.musicPage = "playing" }
            }

            Rectangle {
                width: (parent.width - 8) / 2; height: 32; radius: 8
                color: root.musicPage === "lyrics" ? Theme.accent : Theme.cardHi
                border.color: root.musicPage === "lyrics" ? "transparent" : Theme.border
                border.width: 1
                Text { text: "Lyrics"; color: root.musicPage === "lyrics" ? "white" : Theme.fg; font.pixelSize: 12; anchors.centerIn: parent }
                MouseArea { anchors.fill: parent; onClicked: root.musicPage = "lyrics" }
            }
        }

        // --- SECTION 2: TRACK METADATA (TITLE AND ARTIST STACK) ---
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: Media.title
                color: Theme.fg
                font.pixelSize: 18
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: Media.artist
                color: Theme.dim
                font.pixelSize: 14
                elide: Text.ElideRight
                width: parent.width
            }
        }

        // --- SECTION 3: TIMELINE AND SLIDER BAR WRAPPER ---
        Item {
            width: parent.width
            height: 24

            Text {
                text: root.fmt(Media.position)
                color: Theme.dim
                font.pixelSize: 11
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            // Beautiful custom progress slider line
            Rectangle {
                id: progressTrack
                width: parent.width - 70
                height: 4
                radius: 2
                color: Theme.track
                anchors.centerIn: parent

                Rectangle {
                    width: Media.length > 0 ? parent.width * Math.min(1, (Media.position / 1000000) / Media.length) : 0
                    height: parent.height
                    radius: 2
                    color: Theme.accent
                }
            }

            Text {
                text: root.fmt(Media.length)
                color: Theme.dim
                font.pixelSize: 11
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: progressTrack
                hoverEnabled: true
                onClicked: (mouse) => { if (Media.length > 0) Media.seek(mouse.x / width * Media.length) }
                onPositionChanged: (mouse) => { if (pressed && Media.length > 0) Media.seek(mouse.x / width * Media.length) }
            }
        }

        // --- SECTION 4: SPACED MEDIA CONTROLS ROW ---
        Row {
            width: parent.width
            height: 48
            spacing: (parent.width - (24 + 48 + 24)) / 2

            // Skip Back
            Item {
                width: 24; height: 24
                anchors.verticalCenter: parent.verticalCenter
                Glyph { anchors.centerIn: parent; width: 24; height: 24; kind: "prev"; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: Media.previous() }
            }

            // Play/Pause - Circular dynamic active button
            Rectangle {
                width: 48; height: 48; radius: 24
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter

                Glyph {
                    anchors.centerIn: parent
                    width: 22; height: 22
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

            // Skip Forward
            Item {
                width: 24; height: 24
                anchors.verticalCenter: parent.verticalCenter
                Glyph { anchors.centerIn: parent; width: 24; height: 24; kind: "next"; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: Media.next() }
            }
        }
    }

    // --- LYRICS PAGE ---
    Item {
        x: 220
        y: 24
        width: root.rightW
        height: parent.height - 48
        visible: Media.hasPlayer && root.musicPage === "lyrics"
        anchors.rightMargin: 24

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                width: parent.width
                text: "Lyrics"
                color: Theme.fg
                font.pixelSize: 18
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: parent.height - 40
                radius: 12
                color: Theme.cardHi
                border.color: Theme.border
                border.width: 1

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 16
                    contentHeight: lyricsText.implicitHeight
                    clip: true

                    Text {
                        id: lyricsText
                        width: parent.width
                        text: Media.lyrics || "No lyrics available for this track"
                        color: Theme.fg
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    // Empty state when no player
    Item {
        anchors.fill: parent
        visible: !Media.hasPlayer

        Text {
            anchors.centerIn: parent
            text: "Nothing playing"
            color: Theme.dim
            font.pixelSize: 18
        }
    }
}