// island/services/Media.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root
    property bool tracking: false

    readonly property var players: Mpris.players.values
    readonly property var active: players.find(p => p.isPlaying) ?? players[0] ?? null

    readonly property bool hasPlayer: active !== null
    readonly property bool isPlaying: active ? active.isPlaying : false
    readonly property string title: active ? (active.trackTitle || "") : ""
    readonly property string artist: active ? (active.trackArtist || "") : ""
    readonly property real position: active ? active.position : 0   // seconds
    readonly property real length: active ? active.length : 0       // seconds
    readonly property bool shuffleOn: active ? active.shuffle : false
    readonly property bool repeatOn: active ? active.loopState !== MprisLoopState.None : false

    readonly property string trackUrl: (active && active.metadata)
        ? String(active.metadata["xesam:url"] || "") : ""

    // real art if the player gives one, else YouTube thumbnail from the URL
    readonly property string artUrl: {
        const a = active ? (active.trackArtUrl || "") : ""
        if (a) return a
        const m = /(?:[?&]v=|youtu\.be\/)([\w-]{11})/.exec(trackUrl)
        return m ? "https://img.youtube.com/vi/" + m[1] + "/hqdefault.jpg" : ""
    }

    // MPRIS doesn't push position updates, so poll while playing
    Timer {
        running: root.isPlaying && root.tracking
        interval: 500
        repeat: true
        onTriggered: if (root.active) root.active.positionChanged()
    }

    function togglePlay() { if (active && active.canTogglePlaying) active.togglePlaying() }
    function next()       { if (active && active.canGoNext) active.next() }
    function previous()   { if (active && active.canGoPrevious) active.previous() }
    function toggleShuffle() { if (active && active.shuffleSupported) active.shuffle = !active.shuffle }
    function toggleRepeat() {
        if (!active || !active.loopSupported) return
        active.loopState = (active.loopState === MprisLoopState.None) ? MprisLoopState.Playlist : MprisLoopState.None
    }
    function seek(sec) { if (active && active.canSeek) active.position = sec }
}