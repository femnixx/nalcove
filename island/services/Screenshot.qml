// island/services/Screenshot.qml - Screenshot service using grim/slurp

pragma Singleton
import QtQuick 2.15
import Quickshell.Io

Item {
    id: screenshotService

    property string saveDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
    property bool copyToClipboard: true
    property bool saveToFile: true

    Process {
        id: mkdirProc
        command: ["mkdir", "-p", screenshotService.saveDir]
    }

    Component {
        id: grimComponent
        Process {
            property string filename: ""
            onRunningChanged: {
                if (!running && exitCode === 0 && screenshotService.copyToClipboard) {
                    screenshotService.copyToClipboard(filename)
                }
            }
        }
    }

    Component {
        id: slurpComponent
        Process {
            property string filename: ""
            stdout: StdioCollector {
                onStreamFinished: {
                    if (text && text.trim()) {
                        var region = text.trim()
                        var proc = grimComponent.createObject(screenshotService, { filename: filename })
                        proc.command = ["grim", "-g", region, filename]
                        proc.running = true
                    }
                }
            }
        }
    }

    Component {
        id: hyprComponent
        Process {
            command: ["hyprctl", "activewindow", "-j"]
            property string filename: ""
            stdout: StdioCollector {
                onStreamFinished: {
                    if (text && text.trim()) {
                        try {
                            var win = JSON.parse(text)
                            if (win && win.at) {
                                var geom = win.at[0] + "," + win.at[1] + " " + win.size[0] + "x" + win.size[1]
                                var proc = grimComponent.createObject(screenshotService, { filename: filename })
                                proc.command = ["grim", "-g", geom, filename]
                                proc.running = true
                            }
                        } catch(e) {
                            screenshotService.takeRegion()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: copyComponent
        Process {
            property string filePath: ""
        }
    }

    // Fullscreen screenshot
    function takeFullscreen() {
        var timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
        var filename = saveDir + "/Screenshot_" + timestamp + ".png"
        var proc = grimComponent.createObject(screenshotService, { filename: filename })
        proc.command = ["grim", filename]
        proc.running = true
    }

    // Region screenshot (interactive selection)
    function takeRegion() {
        var timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
        var filename = saveDir + "/Screenshot_" + timestamp + ".png"
        var proc = slurpComponent.createObject(screenshotService, { filename: filename })
        proc.command = ["slurp"]
        proc.running = true
    }

    // Window screenshot (focused window)
    function takeWindow() {
        var timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
        var filename = saveDir + "/Screenshot_" + timestamp + ".png"
        var proc = hyprComponent.createObject(screenshotService, { filename: filename })
        proc.running = true
    }

    // Copy image file to clipboard
    function copyToClipboard(filePath) {
        var proc = copyComponent.createObject(screenshotService, { filePath: filePath })
        proc.command = ["wl-copy", "-t", "image/png", "--", filePath]
        proc.running = true
    }

    Component.onCompleted: {
        mkdirProc.running = true
    }
}