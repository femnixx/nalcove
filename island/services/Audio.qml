pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Track all nodes so their audio properties are populated (needed for volume and for the lists below)
    PwObjectTracker { objects: Pipewire.nodes.values }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property var sinks: Pipewire.nodes.values.filter(n => !n.isStream && n.isSink && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isStream && !n.isSink && n.audio)

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
    function setDefaultSink(n)   { if (n) Pipewire.preferredDefaultAudioSink = n }
    function setDefaultSource(n) { if (n) Pipewire.preferredDefaultAudioSource = n }
}