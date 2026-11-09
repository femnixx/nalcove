// island/services/Shelf.qml - Shelf staging area with drag-and-drop support

pragma Singleton
import QtQuick 2.15
import Quickshell.Io

Item {
    id: shelfService

    property string shelfPath: "/home/archlinux/Downloads/NotchShelf"
    property var stagedFiles: []

    Component.onCompleted: {
        // Create shelf directory if it doesn't exist
        var dir = File(shelfPath)
        if (!dir.exists) {
            dir.mkpath(".")
        }
        // Load existing staged files
        refreshStagedFiles()
    }

    function refreshStagedFiles() {
        var dir = File(shelfPath)
        if (dir.exists) {
            var entries = dir.entryList(["*"], File.Files | File.NoDotAndDotDot)
            stagedFiles = []
            for (var i = 0; i < entries.length; i++) {
                var fileInfo = File(shelfPath + "/" + entries[i])
                stagedFiles.push({
                    name: entries[i],
                    path: shelfPath + "/" + entries[i],
                    size: fileInfo.size,
                    modified: fileInfo.lastModified
                })
            }
        }
    }

    function addFile(sourcePath) {
        var destPath = shelfPath + "/" + File(sourcePath).name
        // Copy file to shelf
        if (File.copy(sourcePath, destPath)) {
            refreshStagedFiles()
            return true
        }
        return false
    }

    function removeFile(fileName) {
        var filePath = shelfPath + "/" + fileName
        if (File.remove(filePath)) {
            refreshStagedFiles()
            return true
        }
        return false
    }

    function clearAll() {
        var dir = File(shelfPath)
        if (dir.exists) {
            var entries = dir.entryList(["*"], File.Files | File.NoDotAndDotDot)
            for (var i = 0; i < entries.length; i++) {
                File.remove(shelfPath + "/" + entries[i])
            }
            refreshStagedFiles()
        }
    }

    function openShelf() {
        var openProc = Process {
            command: ["xdg-open", shelfPath]
        }
        openProc.running = true
    }

    // Handle file drop from external apps
    function handleDrop(urls) {
        var added = []
        for (var i = 0; i < urls.length; i++) {
            var url = urls[i]
            var localPath = url.startsWith("file://") ? url.slice(7) : url
            if (addFile(localPath)) {
                added.push(File(localPath).name)
            }
        }
        return added
    }
}