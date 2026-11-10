// island/services/Screenshot.qml - Screenshot service using grim/slurp

pragma Singleton
import QtQuick 2.15
import Quickshell.Io

Item {
    id: screenshotService

    property string saveDir: "/home/archlinux/Pictures/Screenshots"
    property bool copyToClipboard: true
    property bool saveToFile: true

    Process {
        id: mkdirProc
        command: ["mkdir", "-p", screenshotService.saveDir]
    }

    // Fullscreen screenshot
    function takeFullscreen() {
        var timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
        var filename = saveDir + "/Screenshot_" + timestamp + ".png"
        
        var grimProc = Process {
            command: ["grim", filename]
            onCompleted: function() {
                if (grimProc.exitCode === 0 && copyToClipboard) {
                    copyToClipboard(filename)
                }
            }
        }
        grimProc.running = true
    }

    // Region screenshot (interactive selection)
    function takeRegion() {
        var timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
        var filename = saveDir + "/Screenshot_" + timestamp + ".png"
        
        var slurpProc = Process {
            command: ["slurp"]
            stdout: StdioCollector {
                onStreamFinished: {
                    if (text && text.trim()) {
                        var region = text.trim()
                        var grimProc = Process {
                            command: ["grim", "-g", region, filename]
                            onCompleted: function() {
                                if (grimProc.exitCode === 0 && copyToClipboard) {
                                    copyToClipboard(filename)
                                }
                            }
                        }
                        grimProc.running = true
                    }
                }
            }
        }
        slurpProc.running = true
    }

    // Window screenshot (focused window)
    function takeWindow() {
        var timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, -5)
        var filename = saveDir + "/Screenshot_" + timestamp + ".png"
        
        // Get focused window geometry using hyprctl or similar
        var hyprProc = Process {
            command: ["hyprctl", "activewindow", "-j"]
            stdout: StdioCollector {
                onStreamFinished: {
                    if (text && text.trim()) {
                        try {
                            var win = JSON.parse(text)
                            if (win && win.at) {
                                var geom = win.at[0] + "," + win.at[1] + " " + win.size[0] + "x" + win.size[1]
                                var grimProc = Process {
                                    command: ["grim", "-g", geom, filename]
                                    onCompleted: function() {
                                        if (grimProc.exitCode === 0 && copyToClipboard) {
                                            copyToClipboard(filename)
                                        }
                                    }
                                }
                                grimProc.running = true
                            }
                        } catch(e) {
                            // Fallback to region select
                            takeRegion()
                        }
                    }
                }
            }
        }
        hyprProc.running = true
    }

    // Copy image file to clipboard
    function copyToClipboard(filePath) {
        var copyProc = Process {
            command: ["wl-copy", "-t", "image/png", "--", filePath]
        }
        copyProc.running = true
    }

    Component.onCompleted: {
        mkdirProc.running = true
    }
}