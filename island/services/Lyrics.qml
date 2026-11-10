pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string status: "idle"
    property var lines: []
    property string plain: ""
    property int users: 0

    readonly property string trackKey:
        Media.hasPlayer && Media.title !== ""
            ? Media.artist + "|" + Media.title + "|" + Math.round(Media.length) : ""

    readonly property int activeIndex: {
        if (status !== "synced" || lines.length === 0) return -1
        var t = Media.position + 0.25
        var lo = 0, hi = lines.length - 1, ans = -1
        while (lo <= hi) {
            var mid = (lo + hi) >> 1
            if (lines[mid].t <= t) { ans = mid; lo = mid + 1 } else hi = mid - 1
        }
        return ans
    }

    property var _cache: ({})
    property string _loadedKey: ""
    property int _req: 0

    onTrackKeyChanged: debounce.restart()
    onUsersChanged: if (users > 0 && _loadedKey !== trackKey) load()
    Timer { id: debounce; interval: 400; onTriggered: if (root.users > 0) root.load() }

    function clean(s) {
        return (s || "")
            .replace(/\s*[\(\[][^\)\]]*(official|video|audio|lyrics?|remaster(ed)?|visualizer|hd|hq|live)[^\)\]]*[\)\]]/ig, "")
            .replace(/\s*-\s*topic$/i, "")
            .replace(/\s+/g, " ").trim()
    }

    function parseLrc(s) {
        var out = []
        s.split("\n").forEach(line => {
            var re = /\[(\d+):(\d+(?:\.\d+)?)\]/g
            var times = [], m, last = 0
            while ((m = re.exec(line)) !== null) {
                times.push(parseInt(m[1]) * 60 + parseFloat(m[2]))
                last = re.lastIndex
            }
            var text = line.slice(last).trim()
            times.forEach(t => out.push({ t: t, text: text }))
        })
        out.sort((a, b) => a.t - b.t)
        return out
    }

    function retry() { delete _cache[trackKey]; load() }

    function load() {
        var key = trackKey
        _loadedKey = key
        if (key === "") { _finish("idle", [], "", false); return }
        if (_cache[key]) {
            var c = _cache[key]
            lines = c.lines; plain = c.plain; status = c.status
            return
        }
        status = "loading"; lines = []; plain = ""
        var req = ++_req
        var artist = clean(Media.artist), title = clean(Media.title)
        var args = ["curl", "-s", "-G", "--max-time", "8", "-A", "island-shell/1.0",
                    "https://lrclib.net/api/get",
                    "--data-urlencode", "artist_name=" + artist,
                    "--data-urlencode", "track_name=" + title]
        if (Media.length > 0) args.push("--data-urlencode", "duration=" + Math.round(Media.length))
        _run(req, "get", args)
    }

    function _run(req, kind, args) {
        var p = procC.createObject(root, { command: args, req: req, kind: kind })
        p.running = true
    }
    Component {
        id: procC
        Process {
            id: p
            property int req: 0
            property string kind: ""
            stdout: StdioCollector { onStreamFinished: { root._done(p.req, p.kind, text); p.destroy(500) } }
        }
    }

    function _search(req, kind, params) {
        var args = ["curl", "-s", "-G", "--max-time", "8", "-A", "island-shell/1.0", "https://lrclib.net/api/search"]
        params.forEach(kv => args.push("--data-urlencode", kv))
        _run(req, kind, args)
    }

    function _pick(data) {
        if (!Array.isArray(data)) return null
        var best = null, bestScore = 1e9
        data.forEach(d => {
            if (!(d.syncedLyrics || d.plainLyrics)) return
            var s = Math.abs((d.duration || 0) - Media.length) + (d.syncedLyrics ? 0 : 1000)
            if (s < bestScore) { best = d; bestScore = s }
        })
        return best
    }

    function _done(req, kind, text) {
        if (req !== _req) return
        if (text.trim() === "") { _finish("error", [], "", false); return }
        var data = null
        try { data = JSON.parse(text) } catch (e) {}

        var hit = kind === "get" ? ((data && (data.syncedLyrics || data.plainLyrics)) ? data : null)
                                 : _pick(data)
        if (hit) { _apply(hit); return }

        var artist = clean(Media.artist), title = clean(Media.title)
        if (kind === "get")         _search(req, "search", ["track_name=" + title, "artist_name=" + artist])
        else if (kind === "search") _search(req, "q", ["q=" + artist + " " + title])
        else                        _finish("none", [], "", true)
    }

    function _apply(d) {
        if (d.syncedLyrics) _finish("synced", parseLrc(d.syncedLyrics), d.plainLyrics || "", true)
        else                _finish("plain", [], d.plainLyrics, true)
    }

    function _finish(st, ls, pl, cache) {
        status = st; lines = ls; plain = pl
        if (cache && _loadedKey !== "") _cache[_loadedKey] = { status: st, lines: ls, plain: pl }
    }
}