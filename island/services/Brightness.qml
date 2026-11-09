pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real level: 0.5      // 0..1
    property bool available: false
    property real _target: 0.5

    Process {
        id: getProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(",")        // dev,class,cur,pct%,max
                if (p.length >= 5) {
                    const cur = parseInt(p[2]), max = parseInt(p[4])
                    if (max > 0) { root.available = true; root.level = cur / max }
                }
            }
        }
    }
    Process { id: setProc }

    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: getProc.running = true }
    Timer {
        id: applyTimer; interval: 80
        onTriggered: {
            setProc.command = ["brightnessctl", "set", Math.max(1, Math.round(root._target * 100)) + "%"]
            setProc.running = true
        }
    }

    function set(v) { level = v; _target = v; applyTimer.restart() }
}