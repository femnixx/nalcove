import QtQuick
import QtQuick.Controls
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

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
        anchors.margins: 16
        spacing: 12

        Row {
            spacing: 12
            Text {
                text: "Notch Shelf"
                color: "#ffffff"
                opacity: 1.0
                font.pixelSize: 18
                font.bold: true
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 8
            Rectangle {
                width: 100; height: 28; radius: 14
                color: Theme.cardHi
                border.color: Theme.border; border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "Open Folder"
                    color: "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: openShelf()
                }
            }
            Rectangle {
                width: 100; height: 28; radius: 14
                color: root.dragOver ? Theme.accent : Theme.cardHi
                border.color: root.dragOver ? Theme.accent : Theme.border; border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: root.dragOver ? "Drop Files" : "Clear All"
                    color: root.dragOver ? "white" : "#ffffff"
                    opacity: 1.0
                    font.pixelSize: 12
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
            height: 120
            radius: 16
            color: root.dragOver ? "#3b8bff30" : "#11ffffff"
            border.color: root.dragOver ? "#3b8bff" : "#33ffffff"
            border.width: root.dragOver ? 2 : 1
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on border.color { ColorAnimation { duration: 200 } }
            Behavior on border.width { NumberAnimation { duration: 200 } }

            Column {
                anchors.centerIn: parent
                spacing: 8
                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: root.dragOver ? "folder-up" : "folder-download"
                    size: 36
                    color: root.dragOver ? "#3b8bff" : "#66ffffff"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.dragOver ? "Drop files here to stage" : "Drag & drop files here to stage"
                    color: root.dragOver ? "#3b8bff" : "#66ffffff"
                    font.pixelSize: 13
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: stagedFiles.length + " file(s) staged"
                    color: "#44ffffff"
                    font.pixelSize: 11
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
            height: parent.height - 220
            model: stagedFiles
            spacing: 6
            delegate: Rectangle {
                width: ListView.view.width
                height: 56
                color: Theme.cardHi
                radius: 10
                clip: true

                property bool hovered: false

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 40; height: 40; radius: 8
                        color: "#2c2c2e"
                        Icon {
                            anchors.centerIn: parent
                            name: "file"
                            size: 20
                            color: "#ffffff"
                        }
                    }

                    Column {
                        spacing: 2
                        Text {
                            text: modelData.name
                            color: "#ffffff"
                            opacity: 1.0
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: parent.width - 140
                        }
                        Text {
                            text: (modelData.size / 1024).toFixed(1) + " KB"
                            color: "#9a9aa0"
                            font.pixelSize: 11
                        }
                    }

                    Item { width: 1 }

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: root.hovered ? Theme.accent : "transparent"
                        border.color: Theme.border; border.width: 1
                        Icon {
                            anchors.centerIn: parent
                            name: "copy"
                            size: 14
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
                font.pixelSize: 14
            }
        }
    }
}