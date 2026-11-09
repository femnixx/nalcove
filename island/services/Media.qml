// island/services/Media.qml - Mpris media service wrapper (singleton)

pragma Singleton
import QtQuick 2.15
import Quickshell.Services.Mpris

Item {
    id: mediaService
    property bool tracking: false

    readonly property var players: Mpris.players.values

    function findActivePlayer() {
        if (!players || players.length === 0) return null;
        for (const p of players) if (p.isPlaying) return p;
        return players[0];
    }

    readonly property MprisPlayer active: findActivePlayer()

    readonly property bool hasPlayer: active !== null
    readonly property bool isPlaying: active?.isPlaying ?? false

    readonly property string title: active?.trackTitle || ""
    readonly property string artist: active?.trackArtist || ""
    readonly property string album: active?.trackAlbum || ""
    readonly property string artUrl: active?.trackArtUrl || ""
    readonly property real position: active?.position ?? 0
    readonly property real length: active?.length ?? 0
    readonly property real volume: active?.volume ?? 1.0

    readonly property bool canShuffle: active?.canShuffle ?? false
    readonly property bool shuffle: active?.shuffle ?? false
    readonly property bool canRepeat: active?.canRepeat ?? false
    readonly property int loopStatus: active?.loopStatus ?? 0

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
            const modes = [0, 1, 2]; // None, Track, Playlist
            const current = active.loopStatus;
            const next = modes[(modes.indexOf(current) + 1) % modes.length];
            active.loopStatus = next;
        }
    }
    function seek(pos) {
        if (active?.canSeek) active.position = pos * 1000000; // MPRIS uses microseconds
    }
    function setVolume(vol) {
        if (active) active.volume = Math.max(0, Math.min(1, vol));
    }
}