import QtQuick
import QtQuick.Controls
import Quickshell.Io

Rectangle {
    id: root
    property real ui: 1
    color: Style.card
    radius: Style.cardRadius
    clip: true

    function s(px) { return Math.round(px * ui) }

    property bool dragOver: false
    property string shelfPath: "/home/archlinux/Downloads/NotchShelf"
    property var stagedFiles: []

    Process {
        id: copyTextProc
        command: ["wl-copy", ""]
    }

    Process {
        id: listProc
        command: ["sh", "-c", "ls -1 " + shelfPath + " 2>/dev/null || mkdir -p " + shelfPath + " && ls -1 " + shelfPath]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var lines = text.trim().split("\n")
                    if (lines.length === 1 && lines[0] === "") {
                        stagedFiles = []
                    } else {
                        var newFiles = []
                        for (var i = 0; i < lines.length; i++) {
                            if (lines[i].trim()) {
                                var filename = lines[i].trim()
                                newFiles.push({
                                    name: filename,
                                    path: shelfPath + "/" + filename,
                                    size: 0,
                                    modified: Date.now()
                                })
                            }
                        }
                        // Get sizes asynchronously
                        for (var j = 0; j < newFiles.length; j++) {
                            getFileSize(newFiles[j].path, j)
                        }
                        stagedFiles = newFiles
                    }
                }
            }
        }
    }

    Process {
        id: statProc
        command: ["stat", "-c%s", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && statIndex >= 0 && statIndex < stagedFiles.length) {
                    var size = parseInt(text.trim())
                    if (!isNaN(size)) {
                        var updated = stagedFiles.slice()
                        updated[statIndex].size = size
                        stagedFiles = updated
                    }
                }
            }
        }
    }

    property int statIndex: -1

    function getFileSize(path, index) {
        statIndex = index
        statProc.command = ["stat", "-c%s", path]
        statProc.running = true
    }

    Process {
        id: copyFileProc
        command: ["cp", "", ""]
    }

    Process {
        id: removeFileProc
        command: ["rm", ""]
    }

    Process {
        id: clearAllProc
        command: ["rm", "-f", ""]
    }

    Process {
        id: openFolderProc
        command: ["xdg-open", ""]
    }

    function refreshStagedFiles() {
        listProc.running = true
    }

    function addFile(sourcePath) {
        var destName = sourcePath.split("/").pop()
        copyFileProc.command = ["cp", sourcePath, shelfPath + "/" + destName]
        copyFileProc.onCompleted = function() {
            if (copyFileProc.exitCode === 0) {
                refreshStagedFiles()
            }
        }
        copyFileProc.running = true
    }

    function removeFile(fileName) {
        removeFileProc.command = ["rm", shelfPath + "/" + fileName]
        removeFileProc.onCompleted = function() {
            if (removeFileProc.exitCode === 0) {
                refreshStagedFiles()
            }
        }
        removeFileProc.running = true
    }

    function clearAll() {
        clearAllProc.command = ["rm", "-f", shelfPath + "/*"]
        clearAllProc.onCompleted = function() {
            if (clearAllProc.exitCode === 0) {
                refreshStagedFiles()
            }
        }
        clearAllProc.running = true
    }

    function openShelf() {
        openFolderProc.command = ["xdg-open", shelfPath]
        openFolderProc.running = true
    }

    Component.onCompleted: {
        refreshStagedFiles()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: refreshStagedFiles()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onEntered: root.dragOver = true
        onExited: root.dragOver = false
    }

    Column {
        anchors.fill: parent
        anchors.margins: s(16)
        spacing: s(12)

        Row {
            spacing: s(12)
            Text {
                text: "Notch Shelf"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 18 * ui
                font.bold: true
            }
        }

        Row {
            anchors.right: parent.right
            spacing: s(8)
            Rectangle {
                width: s(100); height: s(28); radius: s(14)
                color: Style.cardHi
                border.color: Style.border; border.width: s(1)
                Text {
                    anchors.centerIn: parent
                    text: "Open Folder"
                    color: "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12 * ui
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: openShelf()
                }
            }
            Rectangle {
                width: s(100); height: s(28); radius: s(14)
                color: root.dragOver ? Style.accent : Style.cardHi
                border.color: root.dragOver ? Style.accent : Style.border; border.width: s(1)
                Text {
                    anchors.centerIn: parent
                    text: root.dragOver ? "Drop Files" : "Clear All"
                    color: root.dragOver ? "white" : "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12 * ui
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!root.dragOver) {
                            clearAll()
                        }
                    }
                }
            }
        }

        // Drop zone
        Rectangle {
            width: parent.width
            height: s(120)
            radius: s(16)
            color: root.dragOver ? "#3b8bff30" : "#11ffffff"
            border.color: root.dragOver ? "#3b8bff" : "#33ffffff"
            border.width: root.dragOver ? s(2) : s(1)
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }
            Behavior on border.width { NumberAnimation { duration: 200 } }

            Column {
                anchors.centerIn: parent
                spacing: s(8)
                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: root.dragOver ? "folder-up" : "folder-download"
                    size: s(36)
                    color: root.dragOver ? "#3b8bff" : "#66ffffff"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.dragOver ? "Drop files here to stage" : "Drag & drop files here to stage"
                    color: root.dragOver ? "#3b8bff" : "#66ffffff"
                    font.pixelSize: 13 * ui
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: stagedFiles.length + " file(s) staged"
                    color: "#44ffffff"
                    font.pixelSize: 11 * ui
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: openShelf()
            }
        }

        // Staged files list
        ListView {
            width: parent.width
            height: parent.height - s(220)
            model: stagedFiles
            spacing: s(6)
            delegate: Rectangle {
                width: ListView.view.width
                height: s(56)
                color: Style.cardHi
                radius: s(10)
                clip: true

                property bool hovered: false

                Row {
                    anchors.fill: parent
                    anchors.margins: s(12)
                    spacing: s(12)

                    Rectangle {
                        width: s(40); height: s(40); radius: s(8)
                        color: "#2c2c2e"
                        Icon {
                            anchors.centerIn: parent
                            name: "file"
                            size: s(20)
                            color: "#ffffff"
                        }
                    }

                    Column {
                        spacing: s(2)
                        Text {
                            text: modelData.name
                            color: "#ffffff"
                            opacity: 1.0
                            font.pixelSize: 13 * ui
                            elide: Text.ElideRight
                            width: parent.width - s(140)
                        }
                        Text {
                            text: (modelData.size / 1024).toFixed(1) + " KB"
                            color: "#9a9aa0"
                            font.pixelSize: 11 * ui
                        }
                    }

                    Item { width: s(1) }

                    Rectangle {
                        width: s(32); height: s(32); radius: s(16)
                        color: root.hovered ? Style.accent : "transparent"
                        border.color: Style.border; border.width: s(1)
                        Icon {
                            anchors.centerIn: parent
                            name: "copy"
                            size: s(14)
                            color: root.hovered ? "white" : "#9a9aa0"
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.hovered = true
                            onExited: root.hovered = false
                            onClicked: {
                                copyTextProc.command = ["wl-copy", "file://" + modelData.path]
                                copyTextProc.running = true
                            }
                        }
                    }

                    Rectangle {
                        width: s(32); height: s(32); radius: s(16)
                        color: root.hovered ? "#ff453a20" : "transparent"
                        border.color: Style.border; border.width: s(1)
                        Icon {
                            anchors.centerIn: parent
                            name: "trash"
                            size: s(14)
                            color: root.hovered ? "#ff453a" : "#9a9aa0"
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.hovered = true
                            onExited: root.hovered = false
                            onClicked: removeFile(modelData.name)
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.hovered = true
                    onExited: root.hovered = false
                }
            }
        }

        Item {
            visible: stagedFiles.length === 0 && !root.dragOver
            width: parent.width
            height: parent.height
            Text {
                anchors.centerIn: parent
                text: "No staged files"
                color: "#9a9aa0"
                font.pixelSize: 14 * ui
            }
        }
    }
}
