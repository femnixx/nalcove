pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ---------- public state ----------
    property bool wifiEnabled: true
    property bool scanning: false
    property string activeSsid: ""
    property string activeIp: ""
    property string busySsid: ""        // ssid currently connecting or being modified
    property string lastError: ""
    property int users: 0               // ref count: background work only runs while > 0
    property alias networkModel: model  // ListModel: ssid, signal, security, secured, active, saved, uuid

    signal passwordRead(string uuid, string password)

    // ---------- internals ----------
    ListModel { id: model }
    property var _saved: ({})           // ssid -> uuid of saved Wi-Fi profiles
    property var _pending: null         // { ssid, wasSaved } during a connect attempt

    // nmcli -t escapes ":" and "\" inside values, so split properly
    function splitTerse(line) {
        var out = [], cur = "", esc = false
        for (var i = 0; i < line.length; i++) {
            var c = line[i]
            if (esc) { cur += c; esc = false }
            else if (c === "\\") esc = true
            else if (c === ":") { out.push(cur); cur = "" }
            else cur += c
        }
        out.push(cur)
        return out
    }

    function find(ssid) {
        for (var i = 0; i < model.count; i++)
            if (model.get(i).ssid === ssid) return model.get(i)
        return null
    }

    // Keep the ListModel in sync without resetting it (preserves scroll and delegate state)
    function syncModel(arr) {
        for (var i = model.count - 1; i >= 0; i--) {
            var gone = true
            for (var a = 0; a < arr.length; a++) if (arr[a].ssid === model.get(i).ssid) { gone = false; break }
            if (gone) model.remove(i)
        }
        for (var j = 0; j < arr.length; j++) {
            var idx = -1
            for (var k = j; k < model.count; k++) if (model.get(k).ssid === arr[j].ssid) { idx = k; break }
            if (idx === -1) model.insert(j, arr[j])
            else { if (idx !== j) model.move(idx, j, 1); model.set(j, arr[j]) }
        }
    }

    // ---------- refresh pipeline: radio -> saved profiles -> scan list ----------
    function refresh() {
        radioCmd.run(["nmcli", "-t", "radio", "wifi"])
        savedCmd.run(["nmcli", "-t", "-e", "yes", "-f", "NAME,UUID,TYPE", "connection", "show"])
    }

    Cmd { id: radioCmd; onDone: out => root.wifiEnabled = out.trim() === "enabled" }

    Cmd {
        id: savedCmd
        onDone: out => {
            var m = {}
            out.split("\n").forEach(l => {
                if (!l) return
                var f = root.splitTerse(l)
                // Heuristic: profile name == ssid (NetworkManager's default). A profile renamed in
                // GNOME Settings won't be matched. For exact matching, query
                // `nmcli -g 802-11-wireless.ssid connection show uuid <uuid>` per profile.
                if (f[2] === "802-11-wireless") m[f[0]] = f[1]
            })
            root._saved = m
            listCmd.run(["nmcli", "-t", "-e", "yes", "-f", "IN-USE,SSID,SIGNAL,SECURITY",
                         "dev", "wifi", "list", "--rescan", "no"])
        }
    }

    Cmd {
        id: listCmd
        onDone: out => {
            var best = {}, active = ""
            out.split("\n").forEach(l => {
                if (!l) return
                var f = root.splitTerse(l)
                var ssid = f[1]
                if (!ssid) return                        // hidden networks have no ssid
                var sig = parseInt(f[2]) || 0
                var isActive = f[0] === "*"
                if (isActive) active = ssid
                var cur = best[ssid]
                // one row per ssid: keep the active one, otherwise the strongest
                if (!cur || isActive || (!cur.active && sig > cur.signal)) {
                    best[ssid] = {
                        ssid: ssid, signal: sig, security: f[3],
                        secured: f[3] !== "" && f[3] !== "--",
                        active: isActive,
                        saved: root._saved[ssid] !== undefined,
                        uuid: root._saved[ssid] || ""
                    }
                }
            })
            var arr = Object.keys(best).map(k => best[k])
            // active first, then saved, then signal in coarse buckets (so rows don't jitter), then name
            arr.sort((a, b) =>
                (b.active - a.active) || (b.saved - a.saved) ||
                (Math.round(b.signal / 20) - Math.round(a.signal / 20)) ||
                a.ssid.localeCompare(b.ssid))
            root.syncModel(arr)
            root.activeSsid = active
            root.refreshIp()
        }
    }

    function refreshIp() {
        var n = find(activeSsid)
        if (n && n.uuid) ipCmd.run(["nmcli", "-g", "IP4.ADDRESS", "connection", "show", "uuid", n.uuid])
        else activeIp = ""
    }
    Cmd { id: ipCmd; onDone: out => root.activeIp = out.split("\n")[0].trim() }

    // ---------- actions ----------
    function setWifiEnabled(on) { radioSetCmd.run(["nmcli", "radio", "wifi", on ? "on" : "off"]) }
    Cmd { id: radioSetCmd; onFinished: code => root.refresh() }

    function rescan() {
        scanning = true
        rescanCmd.run(["nmcli", "dev", "wifi", "rescan"])
    }
    Cmd { id: rescanCmd; onFinished: code => scanDone.restart() }
    Timer { id: scanDone; interval: 2500; onTriggered: { root.scanning = false; root.refresh() } }

    // Connect. Saved profile: bring it up. New secured network: pass the password.
    // `-w 20` stops nmcli blocking for its default ~90 s when the password is wrong.
    function connectTo(ssid, password) {
        lastError = ""
        busySsid = ssid
        var n = find(ssid)
        _pending = { ssid: ssid, wasSaved: !!(n && n.saved) }
        if (n && n.saved)
            connCmd.run(["nmcli", "-w", "20", "connection", "up", "uuid", n.uuid])
        else if (password && password.length > 0)
            connCmd.run(["nmcli", "-w", "20", "dev", "wifi", "connect", ssid, "password", password])
        else
            connCmd.run(["nmcli", "-w", "20", "dev", "wifi", "connect", ssid])
    }
    Cmd {
        id: connCmd
        onFinished: code => {
            root.busySsid = ""
            if (code !== 0) {
                root.lastError = connCmd.err !== "" ? connCmd.err : "Could not connect. Check the password."
                // A failed first-time connect leaves a broken profile behind. Remove it.
                if (root._pending && !root._pending.wasSaved)
                    cleanupCmd.run(["nmcli", "connection", "delete", "id", root._pending.ssid])
            }
            root._pending = null
            root.refresh()
        }
    }
    Cmd { id: cleanupCmd; onFinished: code => root.refresh() }

    function disconnect(uuid) { downCmd.run(["nmcli", "connection", "down", "uuid", uuid]) }
    Cmd { id: downCmd; onFinished: code => root.refresh() }

    function forget(uuid) { forgetCmd.run(["nmcli", "connection", "delete", "uuid", uuid]) }
    Cmd { id: forgetCmd; onFinished: code => root.refresh() }

    function setAutoconnect(uuid, on) {
        autoCmd.run(["nmcli", "connection", "modify", "uuid", uuid, "connection.autoconnect", on ? "yes" : "no"])
    }
    Cmd { id: autoCmd }

    // Read the saved password (only when the user asks to see it; don't keep it around)
    function readPassword(uuid) {
        pwCmd.uuid = uuid
        pwCmd.run(["nmcli", "-s", "-g", "802-11-wireless-security.psk", "connection", "show", "uuid", uuid])
    }
    Cmd { id: pwCmd; property string uuid: ""; onDone: out => root.passwordRead(uuid, out.trim()) }

    // Edit the saved password, then reconnect if that network is the active one
    function setPassword(uuid, password) {
        lastError = ""
        editCmd.uuid = uuid
        editCmd.run(["nmcli", "connection", "modify", "uuid", uuid,
                     "802-11-wireless-security.psk", password])
    }
    Cmd {
        id: editCmd
        property string uuid: ""
        onFinished: code => {
            if (code !== 0) { root.lastError = editCmd.err || "Could not save password"; return }
            var n = root.find(root.activeSsid)
            if (n && n.uuid === uuid) root.connectTo(root.activeSsid, "")
        }
    }

    // ---------- external settings UIs ----------
    // GNOME's panel needs XDG_CURRENT_DESKTOP=GNOME to render fully outside GNOME (e.g. Niri)
    function openGnomeSettings() {
        Quickshell.execDetached(["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "wifi"])
    }
    // Per-network settings: gnome-control-center has no reliable deep link to one network,
    // so open that exact profile in NetworkManager's connection editor instead.
    function openNetworkEditor(uuid) {
        Quickshell.execDetached(["nm-connection-editor", "--edit", uuid])
    }

    // ---------- background work only while a Wi-Fi tab is open ----------
    Process {
        id: monitor
        running: root.users > 0
        command: ["nmcli", "monitor"]
        stdout: SplitParser { onRead: data => debounce.restart() }
    }
    Timer { id: debounce; interval: 500; onTriggered: root.refresh() }
    Timer { interval: 15000; repeat: true; running: root.users > 0; onTriggered: root.refresh() }
    onUsersChanged: if (users > 0) refresh()
}