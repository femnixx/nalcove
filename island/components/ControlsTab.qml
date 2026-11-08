import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

// Volume (PipeWire), brightness (brightnessctl), mute toggle
Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius

    property real brightness: 0.5

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    // read current brightness whenever the tab becomes visible
    onVisibleChanged: { if (visible) readB.running = true }

    Process {
        id: readB
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                if (parts.length >= 5)
                    root.brightness = parseInt(parts[3]) / 100
            }
        }
    }

    Process {
        id: setB
        property int pct: 50
        command: ["brightnessctl", "set", setB.pct + "%"]
    }
    Timer {
        id: throttle
        interval: 80
        onTriggered: { setB.pct = Math.round(root.brightness * 100); setB.running = true }
    }

    // Volume row
    Text { x: 28; y: 38; text: "Volume"; color: Theme.fg; font.pixelSize: 14 }
    LineSlider {
        x: 140; y: 36; width: 470
        value: root.volume
        fillColor: Theme.accent
        onMoved: (v) => { if (root.sink && root.sink.audio) root.sink.audio.volume = v }
    }
    Text { x: 640; y: 38; text: Math.round(root.volume * 100); color: Theme.dim; font.pixelSize: 13 }

    // Brightness row
    Text { x: 28; y: 90; text: "Brightness"; color: Theme.fg; font.pixelSize: 14 }
    LineSlider {
        x: 140; y: 88; width: 470
        value: root.brightness
        fillColor: "#ffd60a"
        onMoved: (v) => { root.brightness = Math.max(0.01, v); throttle.restart() }
    }
    Text { x: 640; y: 90; text: Math.round(root.brightness * 100); color: Theme.dim; font.pixelSize: 13 }

    // Mute pill
    Rectangle {
        x: 28; y: 146
        width: 110; height: 34; radius: 17
        color: root.muted ? Theme.accent : Theme.cardHi
        Text {
            anchors.centerIn: parent
            text: root.muted ? "Muted" : "Mute"
            color: Theme.fg
            font.pixelSize: 13
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted }
        }
    }
}
