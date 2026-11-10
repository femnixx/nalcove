import QtQuick
import Quickshell.Io

Item {
    id: root
    property var entries: []

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
        spacing: 12
        Text { text: "Clipboard History"; color: "#ffffff"; font.pixelSize: 15; font.bold: true
               anchors.verticalCenter: parent.verticalCenter }
        Rectangle {
            width: 80; height: 26; radius: 13; color: "#22ffffff"
            Text { anchors.centerIn: parent; text: "Clear All"; color: "#ffffff"; font.pixelSize: 11 }
            MouseArea { anchors.fill: parent; onClicked: wipeProc.running = true }
        }
    }

    ListView {
        anchors { top: header.bottom; topMargin: 10; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: root.entries
        spacing: 6
        clip: true
        delegate: Rectangle {
            width: ListView.view.width; height: 34; radius: 10
            color: ma.containsMouse ? "#22ffffff" : "#16ffffff"
            Text {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                text: modelData.replace(/^\d+\t/, "")
                color: "#ffffff"; font.pixelSize: 12
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
    }
}