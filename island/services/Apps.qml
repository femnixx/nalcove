pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var counts: ({})      // desktop-entry id -> launch count
    property var _index: []        // precomputed lowercase search index (built once)

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/island"
    readonly property string statePath: stateDir + "/launch-counts.json"

    // Build the index once, rebuild only when the installed-app list changes.
    // Searching then does no per-keystroke string allocation.
    function rebuild() {
        var out = []
        var apps = DesktopEntries.applications.values
        for (var i = 0; i < apps.length; i++) {
            var e = apps[i]
            if (e.noDisplay) continue
            out.push({
                entry: e,
                id: e.id,
                nameL: (e.name || "").toLowerCase(),
                hay: [e.genericName, e.comment, (e.keywords || []).join(" "), (e.categories || []).join(" ")]
                        .join(" ").toLowerCase()
            })
        }
        _index = out
    }
    Connections { target: DesktopEntries.applications; function onValuesChanged() { root.rebuild() } }

    function score(q, it) {
        var n = it.nameL
        if (n === q) return 1000
        if (n.indexOf(q) === 0) return 800 - n.length          // prefix, shorter names first
        if (n.indexOf(" " + q) >= 0) return 600                // start of a later word
        if (n.indexOf(q) >= 0) return 400                      // substring
        if (it.hay.indexOf(q) >= 0) return 200                 // description / keywords / categories
        var pos = 0                                            // fuzzy subsequence: "ffx" -> "firefox"
        for (var k = 0; k < q.length; k++) {
            pos = n.indexOf(q[k], pos)
            if (pos < 0) return 0
            pos++
        }
        return 100
    }

    function search(query, limit) {
        var q = (query || "").trim().toLowerCase()
        var res = []
        for (var i = 0; i < _index.length; i++) {
            var it = _index[i]
            var s = q === "" ? 1 : score(q, it)
            if (s > 0) res.push({ s: s + Math.min(counts[it.id] || 0, 30), n: it.nameL, e: it.entry })
        }
        res.sort((a, b) => (b.s - a.s) || a.n.localeCompare(b.n))
        return res.slice(0, limit || 8).map(r => r.e)           // empty query -> most used apps first
    }

    function launch(entry) {
        if (!entry) return
        entry.execute()
        var c = counts
        c[entry.id] = (c[entry.id] || 0) + 1
        counts = c
        store.setText(JSON.stringify(c))
    }

    FileView {
        id: store
        path: root.statePath
        onLoaded: { try { root.counts = JSON.parse(text()) } catch (e) { root.counts = {} } }
        onLoadFailed: root.counts = {}
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", stateDir])     // FileView won't create the folder
        rebuild()
    }
}