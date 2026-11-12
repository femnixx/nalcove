import QtQuick
import Quickshell.Io

Item {
    id: root
    property real ui: 1
    property var entries: []

    function s(px) { return Math.round(px * ui) }

    // 1) the list
    Process {
        id: listProc
        command: ["sh", "-c", "cliphist list | head -n 50"]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.trim() === "" ? [] : text.trim().split("\n")
        }
    }

    // 2) event source: wl-paste runs `echo x` on every clipboard change
    Process {
        id: watcher
        running: true
        command: ["wl-paste", "--watch", "echo", "x"]
        stdout: SplitParser { onRead: debounce.restart() }
        onExited: restart.start()
    }
    Timer { id: restart; interval: 1000; onTriggered: watcher.running = true }
    Timer { id: debounce; interval: 200; onTriggered: listProc.running = true }

    Process { id: copyProc }
    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
        onRunningChanged: if (!running) listProc.running = true
    }

    Component.onCompleted: listProc.running = true
    onVisibleChanged: if (visible) listProc.running = true

    Row {
        id: header
        spacing: s(12)
        Text { text: "Clipboard History"; color: "#ffffff"; font.pixelSize: 15 * ui; font.bold: true
               anchors.verticalCenter: parent.verticalCenter }
        Rectangle {
            width: s(80); height: s(26); radius: s(13); color: "#22ffffff"
            Text { anchors.centerIn: parent; text: "Clear All"; color: "#ffffff"; font.pixelSize: 11 * ui }
            MouseArea { anchors.fill: parent; onClicked: wipeProc.running = true }
        }
    }

    ListView {
        anchors { top: header.bottom; topMargin: s(10); left: parent.left; right: parent.right; bottom: parent.bottom }
        model: root.entries
        spacing: s(6)
        clip: true
        delegate: Rectangle {
            width: ListView.view.width; height: s(34); radius: s(10)
            color: ma.containsMouse ? "#22ffffff" : "#16ffffff"
            Text {
                anchors.fill: parent; anchors.leftMargin: s(12); anchors.rightMargin: s(12)
                text: modelData.replace(/^\d+\t/, "")
                color: "#ffffff"; font.pixelSize: 12 * ui
                elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                id: ma; anchors.fill: parent; hoverEnabled: true
                onClicked: {
                    copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", modelData]
                    copyProc.running = true
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.entries.length === 0
        text: "Clipboard is empty"; color: "#66ffffff"
        font.pixelSize: 13 * ui
    }
}
