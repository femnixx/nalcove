pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // ---------- PipeWire: volume, mute, defaults (needs bound nodes) ----------
    PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }
    PwObjectTracker { objects: Pipewire.nodes.values }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool sinkReady: sink !== null && sink.ready && sink.audio !== null
    readonly property bool sourceReady: source !== null && source.ready && source.audio !== null

    readonly property real sinkVolume: sinkReady ? sink.audio.volume : 0
    readonly property bool sinkMuted: sinkReady ? sink.audio.muted : false
    readonly property real sourceVolume: sourceReady ? source.audio.volume : 0
    readonly property bool sourceMuted: sourceReady ? source.audio.muted : false

    function label(n) { return n ? (n.description || n.nickname || n.name) : "No device" }

    function setSinkVolume(v) {
        if (!sinkReady) return
        sink.audio.volume = Math.max(0, Math.min(1, v))
    }
    function setSourceVolume(v) {
        if (!sourceReady) return
        source.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleSinkMute() {
        if (!sinkReady) return
        sink.audio.muted = !sink.audio.muted
    }
    function toggleSourceMute() {
        if (!sourceReady) return
        source.audio.muted = !source.audio.muted
    }

    // Default device: use pactl (same names the lists below contain)
    function setDefaultSink(n)   { if (n && n.name) Quickshell.execDetached(["pactl", "set-default-sink", n.name]) }
    function setDefaultSource(n) { if (n && n.name) Quickshell.execDetached(["pactl", "set-default-source", n.name]) }

    // ---------- Device lists via pactl (independent of node binding) ----------
    property var sinks: []
    property var sources: []

    function _parse(text, isSource) {
        try {
            return JSON.parse(text)
                .filter(d => {
                    // Skip sinks/sources with no usable name
                    if (!d.name || d.name.trim() === "") return false
                    // Skip monitor/virtual devices
                    if (d.name.endsWith(".monitor")) return false
                    if (d.properties && d.properties["device.class"] === "monitor") return false
                    if (isSource && (d.name.endsWith(".monitor")
                               || (d.properties && d.properties["device.class"] === "monitor"))) return false
                    return true
                })
                .map(d => ({ name: d.name, description: d.description || d.name, index: d.index, state: d.state }))
        } catch (e) {
            return []
        }
    }

    Process {
        id: sinkList
        command: ["pactl", "--format=json", "list", "sinks"]
        stdout: StdioCollector { onStreamFinished: root.sinks = root._parse(text, false) }
    }
    Process {
        id: sourceList
        command: ["pactl", "--format=json", "list", "sources"]
        stdout: StdioCollector { onStreamFinished: root.sources = root._parse(text, true) }
    }

    function refreshDevices() {
        if (!sinkList.running) sinkList.running = true
        if (!sourceList.running) sourceList.running = true
    }

    // Event-driven refresh: pactl subscribe prints a line per change.
    Process {
        id: subscribe
        running: true
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: line => { if (/'(new|remove)' on (sink|source) /.test(line)) debounce.restart() }
        }
    }
    Timer { id: debounce; interval: 300; onTriggered: root.refreshDevices() }

    Component.onCompleted: refreshDevices()

    // ---------- Per-application streams (optional; used by AppMixer.qml) ----------
    readonly property var appStreams: Pipewire.nodes.values
        .filter(n => n.isStream && !n.isSink && n.audio)
        .sort((a, b) => a.id - b.id)

    function appName(n) {
        var p = n.properties
        return p["application.name"] || p["node.description"] || n.description || n.name || "Unknown"
    }
    function appDetail(n) { return n.properties["media.name"] || "" }
    function appIconName(n) { return n.properties["application.icon-name"] || "" }
    function setNodeVolume(n, v) { if (n && n.audio) n.audio.volume = Math.max(0, Math.min(1, v)) }
    function toggleNodeMute(n) { if (n && n.audio) n.audio.muted = !n.audio.muted }

    // Move an application stream to a specific sink/output
    function moveStreamToSink(n, sinkName) {
        if (!n || !sinkName) return
        Quickshell.execDetached(["pactl", "move-sink-input", String(n.id), sinkName])
    }
}