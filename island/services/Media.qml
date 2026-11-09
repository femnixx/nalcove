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

    // Process to fetch track URL via playerctl
    // Process to fetch track URL via playerctl
    Process {
        id: playerctlUrlProc
        command: ["playerctl", "metadata", "xesam:url"]
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("playerctlUrlProc finished, text:", text)
                if (text && text.trim() && !text.includes("No player")) {
                    var url = text.trim()
                    mediaService.trackUrl = url
                    updateArtUrl()
                } else {
                    console.log("playerctlUrlProc: no URL returned")
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
        console.log("findBestPlayer: mprisPlayers =", mprisPlayers)
        if (!mprisPlayers) return null

        // Get row count from model
        var len = 0
        if (typeof mprisPlayers.rowCount === "function") {
            len = mprisPlayers.rowCount()
        } else if (typeof mprisPlayers.count === "function") {
            len = mprisPlayers.count()
        } else if (mprisPlayers.count !== undefined) {
            len = mprisPlayers.count
        } else if (mprisPlayers.length !== undefined) {
            len = mprisPlayers.length
        }
        
        console.log("findBestPlayer: len =", len)
        if (len === 0) return null

        // Helper to get player at index - try multiple approaches
        function getPlayer(index) {
            // Try model's values property (keys showed 'values')
            if (mprisPlayers.values && mprisPlayers.values[index] !== undefined) {
                var v = mprisPlayers.values[index]
                console.log("getPlayer via values[", index, "] =", v)
                return v
            }
            // Try model's data method with index
            if (typeof mprisPlayers.data === "function") {
                var idx = mprisPlayers.index(index, 0)
                var data = mprisPlayers.data(idx, 0) // Qt.DisplayRole = 0
                console.log("getPlayer via data(", index, ") =", data)
                return data
            }
            // Try array access
            if (mprisPlayers[index] !== undefined) {
                console.log("getPlayer via array[", index, "] =", mprisPlayers[index])
                return mprisPlayers[index]
            }
            // Try get method
            if (mprisPlayers.get) {
                var g = mprisPlayers.get(index)
                console.log("getPlayer via get(", index, ") =", g)
                return g
            }
            return null
        }

        // Priority 1: Currently playing player
        for (var i = 0; i < len; i++) {
            var p = getPlayer(i)
            console.log("Player", i, ":", p)
            if (p && p.playbackStatus === "Playing") return p
        }

        // Priority 2: Paused player with valid metadata
        for (var i = 0; i < len; i++) {
            var p = getPlayer(i)
            if (p && p.trackTitle && p.trackTitle.length > 0) return p
        }

        // Priority 3: First available
        return getPlayer(0)
    }

    // Active player - updated via updateActivePlayer()
    property var active: null

    // Update active player when mprisPlayers changes
    onMprisPlayersChanged: updateActivePlayer()

    function updateActivePlayer() {
        active = findBestPlayer()
        console.log("updateActivePlayer: active =", active)
        // Fetch URL via playerctl for the new active player
        if (active && active.identity) {
            // Extract playerctl name from dbusName (e.g., "org.mpris.MediaPlayer2.firefox.instance_1_1683" -> "firefox.instance_1_1683")
            var playerctlName = active.dbusName
            if (playerctlName && playerctlName.startsWith("org.mpris.MediaPlayer2.")) {
                playerctlName = playerctlName.replace("org.mpris.MediaPlayer2.", "")
            } else {
                playerctlName = active.identity
            }
            console.log("updateActivePlayer: fetching URL for", playerctlName)
            playerctlUrlProc.command = ["playerctl", "-p", playerctlName, "metadata", "xesam:url"]
            playerctlUrlProc.running = true
        } else {
            // Retry in 1 second if no active player found
            retryTimer.start()
        }
    }

    // Timer to retry finding active player
    Timer {
        id: retryTimer
        interval: 1000
        repeat: false
        onTriggered: updateActivePlayer()
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
    property string trackUrl: ""

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
        trackUrl = active?.trackUrl || active?.url || ""
        updateArtUrl()
        
        if (active) {
            console.log("Active player:", active.identity, "status:", active.playbackStatus, "artUrl:", active.trackArtUrl, "trackUrl:", trackUrl)
            // Debug: print all properties
            var props = []
            for (var key in active) {
                props.push(key + "=" + active[key])
            }
            console.log("Player properties:", props.join(", "))
        }
    }

    function updateArtUrl() {
        var url = active?.trackArtUrl || ""
        if (!url) {
            // Try to extract YouTube thumbnail from trackUrl property
            var trackUrl = mediaService.trackUrl || ""
            if (trackUrl && trackUrl.includes("youtube.com/watch")) {
                var videoId = extractYouTubeVideoId(trackUrl)
                if (videoId) {
                    artUrl = "https://img.youtube.com/vi/" + videoId + "/maxresdefault.jpg"
                    console.log("Generated YouTube artUrl:", artUrl)
                    return
                }
            }
            if (trackUrl && trackUrl.includes("youtu.be/")) {
                var videoId = trackUrl.split("youtu.be/")[1].split("?")[0].split("&")[0]
                if (videoId) {
                    artUrl = "https://img.youtube.com/vi/" + videoId + "/maxresdefault.jpg"
                    console.log("Generated YouTube artUrl:", artUrl)
                    return
                }
            }
            artUrl = ""
            console.log("No artUrl available, trackUrl:", trackUrl)
            return
        }
        if (url.startsWith("file://")) {
            artUrl = url.replace("file://", "")
        } else {
            artUrl = url
        }
        console.log("Using artUrl:", artUrl)
    }

    function extractYouTubeVideoId(url) {
        // Match youtube.com/watch?v=VIDEO_ID
        var match = url.match(/[?&]v=([^&]+)/)
        if (match && match[1]) return match[1]
        return null
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