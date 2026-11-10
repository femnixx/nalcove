// services/Cmd.qml: tiny reusable command runner (one Process, queued, never overlaps)
import QtQuick
import Quickshell.Io

Item {
    id: root
    signal done(string out)      // stdout, emitted when the stream closes
    signal finished(int code)    // exit code, emitted after the process exits
    property string err: ""      // stderr of the last run
    property var _queue: []

    Process {
        id: proc
        onRunningChanged: {
            if (!running) {
                root.finished(exitCode)
                if (root._queue.length > 0) {
                    var next = root._queue.shift()
                    Qt.callLater(() => run(next))
                }
            }
        }
        stdout: StdioCollector { onStreamFinished: root.done(text) }
        stderr: StdioCollector { onStreamFinished: root.err = text.trim() }
    }

    function run(args) {
        if (proc.running) { _queue.push(args); return }
        err = ""
        proc.command = args
        proc.running = true
    }
}