// island/shell.vue - Entry point for Quickshell Dynamic Island
// Run with: qs -p ./island
//
// This file is the Quickshell entry point. It requires the Quickshell QML module
// to be installed. Install Quickshell via: sudo pacman -S quickshell
//
// For local testing without Quickshell, use qmlscene6 with the fallback shell.vue
// in the project root.

// island/shell.vue - Entry point for Quickshell Dynamic Island
// Run with: qs -p ./island
//
// This file is the Quickshell entry point. It requires the Quickshell QML module
// to be installed. Install Quickshell via: sudo pacman -S quickshell
//
// For local testing without Quickshell, use qmlscene6 with the fallback shell.vue
// in the project root.

import QtQuick 2.15

Item {
    id: shellRoot
    width: 100
    height: 100
    visible: true

    // Quickshell ShellRoot is available when Quickshell is installed.
    // This stub is used for testing with qmlscene6 only.
    Rectangle {
        anchors.fill: parent
        color: "black"
        Text {
            anchors.centerIn: parent
            text: "Quickshell not installed\nInstall: sudo pacman -S quickshell"
            color: "red"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
    }
}