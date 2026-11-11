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

    // ---------- Per-application streams (optional; used by AppMixer.qml) ----------
    property var appStreams: []
    property int appStreamRev: 0

    function recomputeAppStreams() {
        appStreams = Pipewire.nodes.values
            .filter(n => {
                var p = n.properties || {}
                // App streams have application.name or media.name properties
                var isApp = p["application.name"] || p["media.name"]
                // Must have audio control
                var hasAudio = n.audio !== null
                return isApp && hasAudio
            })
            .sort((a, b) => a.id - b.id)
        appStreamRev++
    }

    // Periodic refresh so newly appearing app streams (e.g. Waterfox starting)
    // show up in the mixer
    Component.onCompleted: {
        refreshDevices()
        recomputeAppStreams()
    }

    Timer {
        id: appStreamTimer
        interval: 500
        repeat: true
        running: true
        onTriggered: root.recomputeAppStreams()
    }

    function appName(n) {
        var p = n.properties
        return p["application.name"] || p["node.description"] || n.description || n.name || "Unknown"
    }
    function appDetail(n) { return n.properties["media.name"] || "" }
    function appIconName(n) { return resolveAppIcon(n) }

    // Resolve app icon through the chain: application.icon-name -> desktop entry -> fallback
    function resolveAppIcon(n) {
        var p = n.properties || {}

        // 1. application.icon-name from PipeWire
        var icon = p["application.icon-name"]
        if (icon && Quickshell.iconPath(icon, true) !== "") return icon

        // 2. Desktop entry lookup by application.id, application.process.binary, or application.name
        var appId = p["application.id"] || p["application.process.binary"] || p["application.name"]
        if (appId) {
            var apps = DesktopEntries.applications.values
            for (var i = 0; i < apps.length; i++) {
                var e = apps[i]
                var entryId = e.id || ""
                // Match exact, or with .desktop suffix added/removed
                if (entryId === appId ||
                    entryId === appId + ".desktop" ||
                    entryId.replace(/\.desktop$/, "") === appId.replace(/\.desktop$/, "")) {
                    if (e.icon && Quickshell.iconPath(e.icon, true) !== "") return e.icon
                }
            }
        }

        // 3. Neutral fallback
        return "app-window"
    }
    function setNodeVolume(n, v) { if (n && n.audio) n.audio.volume = Math.max(0, Math.min(1, v)) }
    function toggleNodeMute(n) { if (n && n.audio) n.audio.muted = !n.audio.muted }

    // Move an application stream to a specific sink/output
    function moveStreamToSink(n, sinkName) {
        if (!n || !sinkName) return
        Quickshell.execDetached(["pactl", "move-sink-input", String(n.id), sinkName])
    }
}