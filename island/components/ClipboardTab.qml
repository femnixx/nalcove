import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

    property bool useCliphist: false

    ListModel {
        id: clipboardModel
    }

    // Check if cliphist is available
    Process {
        id: checkCliphistProc
        command: ["which", "cliphist"]
        onRunningChanged: {
            if (!running) {
                // In Quickshell, we check if process started successfully
                // For now, assume cliphist is not available and use polling
                pollTimer.running = true
            }
        }
    }

    // Fallback: poll clipboard every 500ms
    Timer {
        id: pollTimer
        interval: 500
        running: false
        repeat: true
        onTriggered: {
            pollTextClipboard.running = true
            pollImageClipboard.running = true
        }
    }

    // Poll clipboard for text
    Process {
        id: pollTextClipboard
        command: ["wl-paste", "-t", "text"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    var t = text.trim()
                    var exists = false
                    for (var i = 0; i < clipboardModel.count; i++) {
                        var item = clipboardModel.get(i)
                        if (item && item.type === "text" && item.content === t) {
                            exists = true
                            break
                        }
                    }
                    if (!exists) {
                        clipboardModel.insert(0, { type: "text", cliphistId: "", content: t, time: new Date().toLocaleTimeString() })
                        if (clipboardModel.count > 200) clipboardModel.remove(clipboardModel.count - 1)
                    }
                }
            }
        }
    }

    // Poll clipboard for images
    Process {
        id: pollImageClipboard
        command: ["sh", "-c", "wl-paste -t image/png > /tmp/clipboard_img_$(date +%s).png 2>/dev/null && echo /tmp/clipboard_img_$(date +%s).png"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim() && text.trim().startsWith("/tmp/")) {
                    var filename = text.trim()
                    var exists = false
                    for (var i = 0; i < clipboardModel.count; i++) {
                        var item = clipboardModel.get(i)
                        if (item && item.type === "image" && item.path === filename) {
                            exists = true
                            break
                        }
                    }
                    if (!exists) {
                        clipboardModel.insert(0, { type: "image", cliphistId: "", path: filename, time: new Date().toLocaleTimeString() })
                        if (clipboardModel.count > 200) clipboardModel.remove(clipboardModel.count - 1)
                    }
                }
            }
        }
    }

    // Copy selected entry to clipboard
    Process {
        id: copyTextProc
        command: ["wl-copy"]
    }

    Process {
        id: copyImageProc
        command: ["wl-copy", "-t", "image/png"]
    }

    function copyToClipboard(text) {
        copyTextProc.command = ["wl-copy", text]
        copyTextProc.running = true
    }

    function copyImageToClipboard(cliphistId) {
        // For fallback mode, we can't easily copy images back
        // This would need cliphist or similar
    }

    function clearHistory() {
        clipboardModel.clear()
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
                                    if (modelData && modelData.type === "text" && modelData.content) {
                                        copyToClipboard(modelData.content)
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
                                onClicked: clipboardModel.remove(index)
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