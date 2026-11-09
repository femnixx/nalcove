pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Audio properties are only available while an object is tracked
    PwObjectTracker { objects: Pipewire.nodes }

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
    function setDefaultSink(n)   { Pipewire.pferredDefaultAudioSink = n }
    function setDefaultSource(n) { Pipewire.preferredDefaultAudioSource = n }

    // Track sinks and sources via ListModels for PwObjectTracker
    PwObjectTracker { objects: sinksModel }
    PwObjectTracker { objects: sourcesModel }
}