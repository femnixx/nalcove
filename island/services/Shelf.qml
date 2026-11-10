pragma Singleton
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Shelf root directory
    readonly property string shelfRoot: Quickshell.env("HOME") + "/Downloads/NotchShelf"

    // Current directory being browsed
    property string currentDir: root.shelfRoot

    // File listing model - using a simple array updated by a Process
    property var fileList: []

    // Places
    readonly property var places: [
        { name: "Shelf", path: root.shelfRoot, icon: "folder-download" },
        { name: "Downloads", path: Quickshell.env("HOME") + "/Downloads", icon: "folder-download" },
        { name: "Documents", path: Quickshell.env("HOME") + "/Documents", icon: "folder-documents" },
        { name: "Pictures", path: Quickshell.env("HOME") + "/Pictures", icon: "folder-pictures" },
        { name: "Desktop", path: Quickshell.env("HOME") + "/Desktop", icon: "folder-desktop" },
        { name: "Music", path: Quickshell.env("HOME") + "/Music", icon: "folder-music" },
        { name: "Videos", path: Quickshell.env("HOME") + "/Videos", icon: "folder-videos" },
        { name: "Home", path: Quickshell.env("HOME"), icon: "folder-home" }
    ]

    // Breadcrumb trail
    property var breadcrumb: [{ name: "Shelf", path: root.shelfRoot }]

    // Drag-over state for drop zone
    property bool dragOver: false

    // Refresh the file list
    function refresh() {
        listProc.running = true
    }

    // Navigate to a directory
    function navigateTo(path) {
        if (path === currentDir) return
        currentDir = path
        updateBreadcrumb(path)
        refresh()
    }

    // Go up one level
    function goUp() {
        var parent = currentDir
        var lastSlash = parent.lastIndexOf("/")
        if (lastSlash > 0) {
            navigateTo(parent.substring(0, lastSlash))
        }
    }

    // Update breadcrumb trail
    function updateBreadcrumb(path) {
        var parts = path.split("/").filter(p => p.length > 0)
        var crumb = [{ name: "Shelf", path: root.shelfRoot }]
        var current = ""
        for (var i = 0; i < parts.length; i++) {
            current += "/" + parts[i]
            if (current !== root.shelfRoot) {
                crumb.push({ name: parts[i], path: current })
            }
        }
        breadcrumb = crumb
    }

    // Add URLs from drag-and-drop
    function addUrls(urls) {
        var paths = []
        for (var i = 0; i < urls.length; i++) {
            var url = urls[i]
            var localPath = url.startsWith("file://") ? url.slice(7) : url
            paths.push(localPath)
        }
        if (paths.length === 0) return

        var proc = addProc
        proc.command = [Quickshell.env("HOME") + "/projects/dynamic-notch-niri/island/scripts/shelf-add.sh", currentDir].concat(paths)
        proc.running = true
    }

    // Open file or folder
    function openPath(path) {
        var proc = openProc
        proc.command = [Quickshell.env("HOME") + "/projects/dynamic-notch-niri/island/scripts/shelf-open.sh", path]
        proc.running = true
    }

    // Copy file path to clipboard
    function copyPath(path) {
        var proc = copyPathProc
        proc.command = ["wl-copy", "--type", "text/uri-list", "file://" + path]
        proc.running = true
    }

    // Copy file to clipboard (for pasting in other apps)
    function copyFile(path) {
        var proc = copyFileProc
        proc.command = ["wl-copy", "--type", "text/uri-list", "file://" + path]
        proc.running = true
    }

    // Move to trash
    function trashPath(path) {
        var proc = trashProc
        proc.command = [Quickshell.env("HOME") + "/projects/dynamic-notch-niri/island/scripts/shelf-trash.sh", path]
        proc.running = true
    }

    // Clear current directory (with confirmation handled in UI)
    function clearDir() {
        // Safety: only allow clearing within shelf root
        if (!currentDir.startsWith(shelfRoot)) return
        var proc = clearProc
        proc.command = ["sh", "-c", "rm -rf -- '" + currentDir + "'/*"]
        proc.running = true
    }

    // Open in file manager
    function openInFileManager() {
        openPath(currentDir)
    }

    // Initialize
    Component.onCompleted: {
        refresh()
    }

    // Processes for async operations
    Process {
        id: listProc
        command: ["sh", "-c", "ls -1 " + root.currentDir + " 2>/dev/null || mkdir -p " + root.currentDir + " && ls -1 " + root.currentDir]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text) {
                    var lines = text.trim().split("\n")
                    if (lines.length === 1 && lines[0] === "") {
                        root.fileList = []
                    } else {
                        var newFiles = []
                        for (var i = 0; i < lines.length; i++) {
                            if (lines[i].trim()) {
                                var filename = lines[i].trim()
                                var filePath = root.currentDir + "/" + filename
                                newFiles.push({
                                    name: filename,
                                    path: filePath,
                                    isDir: false,
                                    fileURL: "file://" + filePath
                                })
                            }
                        }
                        // Check which are directories
                        for (var j = 0; j < newFiles.length; j++) {
                            checkIsDir(newFiles[j].path, j)
                        }
                        root.fileList = newFiles
                    }
                }
            }
        }
    }

    // Check if path is directory
    Process {
        id: checkDirProc
        property int checkIndex: -1
        command: ["sh", "-c", "test -d \"\" && echo dir || echo file"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (checkDirProc.checkIndex >= 0 && checkDirProc.checkIndex < root.fileList.length) {
                    var isDir = text.trim() === "dir"
                    var updated = root.fileList.slice()
                    updated[checkDirProc.checkIndex].isDir = isDir
                    root.fileList = updated
                }
            }
        }
    }

    function checkIsDir(path, index) {
        checkDirProc.checkIndex = index
        checkDirProc.command = ["sh", "-c", "test -d \"" + path + "\" && echo dir || echo file"]
        checkDirProc.running = true
    }

    Process {
        id: addProc
        onExited: {
            if (exitCode === 0) {
                refresh()
            }
        }
    }

    Process {
        id: openProc
    }

    Process {
        id: copyPathProc
    }

    Process {
        id: copyFileProc
    }

    Process {
        id: trashProc
        onExited: {
            if (exitCode === 0) {
                refresh()
            }
        }
    }

    Process {
        id: clearProc
        onExited: {
            if (exitCode === 0) {
                refresh()
            }
        }
    }
}