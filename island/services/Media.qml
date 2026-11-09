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
    readonly property string artUrl: active?.trackArtUrl || ""
    readonly property real position: active?.position ?? 0
    readonly property real length: active?.length ?? 0

    function playPause() {
        if (active?.canTogglePlaying) active.togglePlaying();
    }
    function next() {
        if (active?.canGoNext) active.next();
    }
    function previous() {
        if (active?.canGoPrevious) active.previous();
    }
}