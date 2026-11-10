// services/Shelf.qml: shelf staging area with drag-and-drop support, using Process for file ops

pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: shelfService

    property string shelfPath: "/home/archlinux/Downloads/NotchShelf"
    property var stagedFiles: []

    // Process-based file operations
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

    Process {
        id: copyTextProc
        command: ["wl-copy", ""]
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

    // Handle file drop from external apps
    function handleDrop(urls) {
        var added = []
        for (var i = 0; i < urls.length; i++) {
            var url = urls[i]
            var localPath = url.startsWith("file://") ? url.slice(7) : url
            if (addFile(localPath)) {
                added.push(localPath.split("/").pop())
            }
        }
        return added
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
}