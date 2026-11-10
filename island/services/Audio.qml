pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Track the default sink and source so their audio properties are available
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // Also track all nodes for the device dropdowns and per-app streams
    PwObjectTracker { objects: Pipewire.nodes.values }

    // Filter function for sinks and sources
    function filterNodes(nodes, isSink) {
        var result = []
        for (var i = 0; i < nodes.count; i++) {
            var node = nodes.get(i)
            if (node && !node.isStream && node.isSink === isSink && node.audio) {
                result.push(node)
            }
        }
        return result
    }

    // Use ListModel for sinks and sources so PwObjectTracker can track them
    ListModel { id: sinksModel }
    ListModel { id: sourcesModel }

    // Update models when Pipewire.nodes changes
    Connections {
        target: Pipewire.nodes
        function onRowsInserted() { updateModels() }
        function onRowsRemoved() { updateModels() }
    }

    function updateModels() {
        sinksModel.clear()
        sourcesModel.clear()
        for (var i = 0; i < Pipewire.nodes.count; i++) {
            var node = Pipewire.nodes.get(i)
            if (node && !node.isStream && node.audio) {
                if (node.isSink) sinksModel.append(node)
                else sourcesModel.append(node)
            }
        }
    }

    // Initialize
    Component.onCompleted: updateModels()

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Readiness checks - only true when node is bound and has audio interface
    readonly property bool sinkReady: sink !== null && sink.ready && sink.audio !== null
    readonly property bool sourceReady: source !== null && source.ready && source.audio !== null

    // Volume/muted properties - only return values when ready
    readonly property real sinkVolume: sinkReady ? sink.audio.volume : 0
    readonly property bool sinkMuted: sinkReady ? sink.audio.muted : false
    readonly property real sourceVolume: sourceReady ? source.audio.volume : 0
    readonly property bool sourceMuted: sourceReady ? source.audio.muted : false

    // Per-app streams (playback)
    readonly property var appStreams: Pipewire.nodes.values.filter(n => n.isStream && !n.isSink && n.audio)

    // Per-app capture streams (microphone)
    readonly property var captureStreams: Pipewire.nodes.values.filter(n => n.isStream && n.isSink && n.audio)

    function label(n) { return n ? (n.description || n.nickname || n.name) : "No device" }

    function appName(n) {
        var p = n.properties
        return p["application.name"] || p["node.description"] || n.description || n.name || "Unknown"
    }
    function appDetail(n) { return n.properties["media.name"] || "" }
    function appIconName(n) { return n.properties["application.icon-name"] || "" }

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
    function setDefaultSink(n)   { if (n) Pipewire.preferredDefaultAudioSink = n }
    function setDefaultSource(n) { if (n) Pipewire.preferredDefaultAudioSource = n }
}