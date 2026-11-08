pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// island/services/Media.qml
// Usage in shell.qml:  import "services"   then   Media.isPlaying, Media.title, ...
Singleton {
    id: root

    // Set from shell.qml: Media.tracking = (triggerMode !== "closed")
    // Position polling only runs while playing AND tracking, so nothing runs when closed.
    property bool tracking: false

    readonly property var players: Mpris.players.values

    // Prefer a Playing player, else the first available
    readonly property var player: {
        const list = root.players
        if (!list || list.length === 0)
            return null
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return list[i]
        }
        return list[0]
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player ? player.isPlaying : false
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""
    readonly property string artUrl: player ? player.trackArtUrl : ""
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0
    readonly property bool canSeek: player ? player.canSeek && player.positionSupported : false

    function playPause() { if (player) player.togglePlaying() }
    function next()      { if (player && player.canGoNext) player.next() }
    function previous()  { if (player && player.canGoPrevious) player.previous() }
    function seek(seconds) { if (canSeek) player.position = seconds }

    // MPRIS position does not update by itself, so poke it while needed
    Timer {
        interval: 500
        repeat: true
        running: root.isPlaying && root.tracking
        onTriggered: { if (root.player) root.player.positionChanged() }
    }
}
