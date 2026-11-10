pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var list: []              // newest first
    readonly property int count: list.length
    property int maxItems: 50
    property int _seq: 0
    signal received(var n)             // use this to pop the island open

    function dismiss(id) { list = list.filter(n => n.id !== id) }
    function clearAll()  { list = [] }

    function push(n) {
        const top = list[0]
        // ignore exact duplicates within 1 second
        if (top && top.app === n.app && top.summary === n.summary && top.body === n.body
            && (n.time - top.time) < 1000) return
        list = [n].concat(list).slice(0, maxItems)
        received(n)
    }

    Process {
        id: monitor
        running: true
        command: ["busctl", "--user", "monitor", "--json=short", "--match",
                  "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"]
        stdout: SplitParser {
            onRead: line => {
                if (!line || line[0] !== "{") return
                try {
                    const m = JSON.parse(line)
                    if (m.member !== "Notify" || !m.payload || !m.payload.data) return
                    const d = m.payload.data
                    const hints = d[6] || {}
                    root.push({
                        id: ++root._seq,
                        app: d[0] || "",
                        icon: d[2] || "",
                        summary: d[3] || "",
                        body: d[4] || "",
                        urgency: hints.urgency ? hints.urgency.data : 1,
                        time: new Date()
                    })
                } catch (e) { console.warn("notif parse failed:", e) }
            }
        }
        stderr: SplitParser { onRead: l => console.warn("notif monitor:", l) }
        onExited: restart.start()
    }
    Timer { id: restart; interval: 2000; onTriggered: monitor.running = true }
}