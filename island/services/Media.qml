// island/services/Media.qml - MPRIS media service with web browser fallback

pragma Singleton
import QtQuick 2.15
import Quickshell.Services.Mpris
import Quickshell.Io

Item {
    id: mediaService
    property bool tracking: false

    // Get all MPRIS players from Quickshell's Mpris service
    readonly property var mprisPlayers: (Mpris && Mpris.players) ? Mpris.players : []

    // Process for checking playerctl
    Process {
        id: playerctlListProc
        command: ["playerctl", "-l"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var lines = text.trim().split("\n")
                    var knownNames = getMprisPlayerNames()
                    for (var i = 0; i < lines.length; i++) {
                        var player = lines[i].trim()
                        if (player && knownNames.indexOf(player) === -1) {
                            console.log("Found additional player via playerctl:", player)
                        }
                    }
                }
            }
        }
    }

    // Timer to check for playerctld/web players
    Timer {
        id: playerCheckTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: playerctlListProc.running = true
    }

    function getMprisPlayerNames() {
        var names = []
        if (mprisPlayers) {
            // mprisPlayers might be a QML ListModel or array-like
            var len = mprisPlayers.length || (mprisPlayers.count ? mprisPlayers.count : 0)
            for (var i = 0; i < len; i++) {
                var p = mprisPlayers[i] || (mprisPlayers.get ? mprisPlayers.get(i) : null)
                if (p && p.identity) {
                    names.push(p.identity)
                }
            }
        }
        // Ensure we return a plain JS array with contains method
        return Array.from(names)
    }

    function findBestPlayer() {
        if (!mprisPlayers || mprisPlayers.length === 0) return null

        // Priority 1: Currently playing player
        for (var i = 0; i < mprisPlayers.length; i++) {
            var p = mprisPlayers[i]
            if (p && p.playbackStatus === "Playing") return p
        }

        // Priority 2: Paused player with valid metadata
        for (var i = 0; i < mprisPlayers.length; i++) {
            var p = mprisPlayers[i]
            if (p && p.trackTitle && p.trackTitle.length > 0) return p
        }

        // Priority 3: First available
        return mprisPlayers[0]
    }

    // Active player - updated via updateActivePlayer()
    property var active: null

    // Update active player when mprisPlayers changes
    onMprisPlayersChanged: updateActivePlayer()

    function updateActivePlayer() {
        active = findBestPlayer()
    }

    // Derived properties - use regular properties updated in onActiveChanged
    property bool hasPlayer: false
    property bool isPlaying: false
    property string title: ""
    property string artist: ""
    property string album: ""
    property string lyrics: ""
    property real position: 0
    property real length: 0
    property real volume: 1.0
    property bool canShuffle: false
    property bool shuffle: false
    property bool canRepeat: false
    property int loopStatus: 0
    property string artUrl: ""

    // Update all derived properties when active player changes
    onActiveChanged: {
        hasPlayer = (active !== null)
        isPlaying = (active?.playbackStatus === "Playing")
        title = active?.trackTitle || ""
        artist = active?.trackArtist || ""
        album = active?.trackAlbum || ""
        lyrics = active?.trackLyrics || ""
        position = active?.position ?? 0
        length = active?.length ?? 0
        volume = active?.volume ?? 1.0
        canShuffle = active?.canShuffle ?? false
        shuffle = active?.shuffle ?? false
        canRepeat = active?.canRepeat ?? false
        loopStatus = active?.loopStatus ?? 0
        updateArtUrl()
        
        if (active) {
            console.log("Active player:", active.identity, "status:", active.playbackStatus, "artUrl:", active.trackArtUrl)
        }
    }

    function updateArtUrl() {
        var url = active?.trackArtUrl || ""
        if (!url) {
            artUrl = ""
            return
        }
        if (url.startsWith("file://")) {
            artUrl = url.replace("file://", "")
        } else {
            artUrl = url
        }
    }

    function playPause() {
        if (active?.canTogglePlaying) active.togglePlaying();
    }
    function next() {
        if (active?.canGoNext) active.next();
    }
    function previous() {
        if (active?.canGoPrevious) active.previous();
    }
    function shuffle() {
        if (active?.canShuffle) active.shuffle = !active.shuffle;
    }
    function repeat() {
        if (active?.canRepeat) {
            const modes = [0, 1, 2];
            const current = active.loopStatus;
            const next = modes[(modes.indexOf(current) + 1) % modes.length];
            active.loopStatus = next;
        }
    }
    function seek(pos) {
        if (active?.canSeek) active.position = pos * 1000000;
    }
    function setVolume(vol) {
        if (active) active.volume = Math.max(0, Math.min(1, vol));
    }
}