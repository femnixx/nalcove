import QtQuick
import QtQuick.Controls
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

    Column {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.s2

            Text {
                text: "Clipboard History"
                color: Theme.fg
                font.pixelSize: Theme.tTitle
                font.bold: true
                font.family: Theme.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Pill {
                text: "Clear All"
                danger: true
                height: Theme.controlH
                enabled: root.entries.length > 0
                Layout.alignment: Qt.AlignVCenter
                onClicked: wipeProc.running = true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.cardBorder
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.entries
            spacing: Theme.s2
            clip: true

            delegate: Card {
                width: ListView.view.width
                hoverEnabled: true
                implicitHeight: Theme.controlH

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.s3
                    spacing: Theme.s3

                    Text {
                        width: parent.width
                        text: modelData.replace(/^\d+\t/, "")
                        color: Theme.fg
                        font.pixelSize: Theme.tBody
                        font.family: Theme.fontFamily
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", modelData]
                        copyProc.running = true
                    }
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.entries.length === 0
            icon: "clipboard"
            text: "Clipboard is empty"
        }
    }
}