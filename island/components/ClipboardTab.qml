import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

    property string copyText: ""
    property bool useCliphist: true

    ListModel {
        id: clipboardModel
    }

    // Load history from cliphist on startup
    Process {
        id: loadHistoryProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    var lines = text.trim().split("\n")
                    for (var i = 0; i < lines.length && i < 200; i++) {
                        var line = lines[i].trim()
                        if (line) {
                            var parts = line.split("\t")
                            if (parts.length >= 2) {
                                var id = parts[0]
                                var content = parts.slice(1).join("\t")
                                if (content.startsWith("[image]") || content.startsWith("[IMAGE]")) {
                                    clipboardModel.append({ type: "image", cliphistId: id, content: content, time: "" })
                                } else {
                                    clipboardModel.append({ type: "text", cliphistId: id, content: content, time: "" })
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Watch for clipboard changes using wl-paste --watch
    Process {
        id: watchProc
        command: ["bash", "-c", "wl-paste --watch cliphist store"]
        onRunningChanged: {
            if (!running) {
                reviveTimer.start()
            }
        }
    }

    Timer {
        id: reviveTimer
        interval: 3000
        onTriggered: watchProc.running = true
    }

    // Static processes for clipboard operations
    Process {
        id: copyTextProc
        command: ["wl-copy"]
    }

    Process {
        id: copyImageProc
        command: ["wl-copy", "-t", "image/png"]
    }

    Process {
        id: deleteProc
        command: ["cliphist", "delete", ""]
    }

    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
    }

    function copyToClipboard(text) {
        copyTextProc.command = ["wl-copy", text]
        copyTextProc.running = true
    }

    function copyImageToClipboard(cliphistId) {
        copyImageProc.command = ["bash", "-c", "cliphist decode " + cliphistId + " | wl-copy -t image/png"]
        copyImageProc.running = true
    }

    function deleteEntry(cliphistId) {
        deleteProc.command = ["cliphist", "delete", cliphistId]
        deleteProc.running = true
    }

    function clearHistory() {
        wipeProc.onCompleted = function() {
            if (wipeProc.exitCode === 0) {
                clipboardModel.clear()
            }
        }
        wipeProc.running = true
    }

    Component.onCompleted: {
        loadHistoryProc.running = true
        watchProc.running = true
    }

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
                    onClicked: clearHistory()
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: clipboardModel
            spacing: 6
            delegate: Rectangle {
                width: ListView.view.width
                height: Math.max(72, contentColumn.implicitHeight + 16)
                color: Theme.cardHi
                radius: 10
                clip: true

                property bool hovered: false

                Column {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Text or Image content
                    Loader {
                        width: parent.width
                        sourceComponent: modelData && modelData.type === "image" ? imageDelegate : textDelegate
                    }

                    Component {
                        id: textDelegate
                        Text {
                            id: textItem
                            width: parent.width - 80
                            text: modelData && modelData.content ? modelData.content : ""
                            color: "#ffffff"
                            opacity: 1.0
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }

                    Component {
                        id: imageDelegate
                        Image {
                            width: Math.min(parent.width, 300)
                            height: 160
                            source: modelData && modelData.path ? "file://" + modelData.path : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 8

                        Text {
                            text: modelData && modelData.time ? modelData.time : ""
                            color: "#9a9aa0"
                            font.pixelSize: 10
                            visible: !root.hovered
                        }

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: root.hovered ? Theme.accent : "transparent"
                            border.color: Theme.border; border.width: 1
                            Icon {
                                anchors.centerIn: parent
                                name: modelData && modelData.type === "image" ? "download" : "copy"
                                size: 14
                                color: root.hovered ? "white" : "#9a9aa0"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.hovered = true
                                onExited: root.hovered = false
                                onClicked: {
                                    if (modelData) {
                                        if (modelData.type === "text" && modelData.content) {
                                            copyToClipboard(modelData.content)
                                        } else if (modelData.type === "image" && modelData.cliphistId) {
                                            copyImageToClipboard(modelData.cliphistId)
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: root.hovered ? "#ff453a20" : "transparent"
                            border.color: Theme.border; border.width: 1
                            Icon {
                                anchors.centerIn: parent
                                name: "trash"
                                size: 14
                                color: root.hovered ? "#ff453a" : "#9a9aa0"
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.hovered = true
                                onExited: root.hovered = false
                                onClicked: {
                                    if (modelData && modelData.cliphistId) {
                                        deleteEntry(modelData.cliphistId)
                                        clipboardModel.remove(index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            visible: clipboardModel.count === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 14
            }
        }
    }
}