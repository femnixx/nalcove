import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

    property var entries: []

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.trim() === "" ? [] : text.trim().split("\n")
        }
    }
    Process { id: copyProc }
    Process { id: wipeProc; command: ["cliphist", "wipe"]; onRunningChanged: if (!running) listProc.running = true }

    // refresh whenever the tab becomes visible
    onVisibleChanged: if (visible) listProc.running = true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Row {
            Layout.fillWidth: true
            spacing: 12
            Text {
                text: "Clipboard History"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 18
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 100; height: 28; radius: 14
                color: Theme.cardHi
                border.color: Theme.border; border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: wipeProc.running = true
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.entries
            spacing: 6
            clip: true
            delegate: Rectangle {
                width: ListView.view.width; height: 36; radius: 10
                color: "#16ffffff"
                Text {
                    anchors.fill: parent; anchors.margins: 10
                    text: modelData.replace(/^\d+\t/, "")
                    color: "#ffffff"; elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // entry id is the number before the tab
                        copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", modelData]
                        copyProc.running = true
                    }
                }
            }
        }

        Item {
            visible: root.entries.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: "#9a9aa0"
                font.pixelSize: 14
            }
        }
    }
}