pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Audio properties are only available while an object is tracked
    // Track all nodes so their audio properties are available
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

    readonly property var sinks: filterNodes(Pipewire.nodes, true)
    readonly property var sources: filterNodes(Pipewire.nodes, false)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property real sinkVolume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool sinkMuted: sink && sink.audio ? sink.audio.muted : false
    readonly property real sourceVolume: source && source.audio ? source.audio.volume : 0
    readonly property bool sourceMuted: source && source.audio ? source.audio.muted : false

    function label(n) { return n ? (n.description || n.nickname || n.name) : "No device" }

    function setSinkVolume(v)   { if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, v)) }
    function setSourceVolume(v) { if (source && source.audio) source.audio.volume = Math.max(0, Math.min(1, v)) }
    function toggleSinkMute()   { if (sink && sink.audio) sink.audio.muted = !sink.audio.muted }
    function toggleSourceMute() { if (source && source.audio) source.audio.muted = !source.audio.muted }
    function setDefaultSink(n)   { Pipewire.preferredDefaultAudioSink = n }
    function setDefaultSource(n) { Pipewire.preferredDefaultAudioSource = n }

    // Track all sinks and sources so their audio properties are bound
    PwObjectTracker {
        objects: root.sinks
    }
    PwObjectTracker {
        objects: root.sources
    }
}