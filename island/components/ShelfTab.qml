import QtQuick
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius
    clip: true

    property var items: [
        { name: "Home", path: "/home", icon: "home" },
        { name: "Documents", path: "/home/archlinux/Documents", icon: "folder" },
        { name: "Downloads", path: "/home/archlinux/Downloads", icon: "folder" },
        { name: "Pictures", path: "/home/archlinux/Pictures", icon: "image" },
        { name: "Music", path: "/home/archlinux/Music", icon: "music" },
        { name: "Videos", path: "/home/archlinux/Videos", icon: "camera" },
        { name: "Projects", path: "/home/archlinux/projects", icon: "folder" },
        { name: "Config", path: "/home/archlinux/.config", icon: "settings" }
    ]

    Process {
        id: openProc
        command: ["xdg-open"]
    }

    function openPath(path) {
        openProc.command = ["xdg-open", path]
        openProc.running = true
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Shelf"
            color: Theme.fg
            font.pixelSize: 18
            font.bold: true
        }

        GridView {
            width: parent.width
            height: parent.height - 50
            cellWidth: 120
            cellHeight: 100
            model: root.items

            delegate: Rectangle {
                width: 110; height: 90
                color: Theme.cardHi
                radius: 12
                clip: true

                property bool hovered: false
                property bool pressed: false

                Column {
                    anchors.centerIn: parent
                    spacing: 8

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: modelData.icon
                        size: 32
                        color: Theme.fg
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.name
                        color: Theme.fg
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        width: 100
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.hovered = true
                    onExited: root.hovered = false
                    onPressed: root.pressed = true
                    onReleased: root.pressed = false
                    onClicked: openPath(modelData.path)
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                color: pressed ? Theme.accentFill : (hovered ? Theme.cardHi : Theme.cardHi)
                border.color: hovered ? Theme.accent : "transparent"
                border.width: hovered ? 2 : 0
            }
        }
    }
}