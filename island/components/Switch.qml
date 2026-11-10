import QtQuick
import qs.components 1.0


Rectangle {
    id: root
    width: 44
    height: 26
    radius: 13

    property bool checked: false
    property bool enabled: true
    property var onToggled: null

    color: root.enabled ? (root.checked ? Theme.accent : Theme.track) : Theme.track
    border.color: "transparent"
    border.width: 0

    Behavior on color { ColorAnimation { duration: Theme.dFast; easing.type: Theme.easingOutCubic } }

    Rectangle {
        x: root.checked ? root.width - height : 0
        y: 0
        width: root.height
        height: root.height
        radius: root.height / 2
        color: "#ffffff"
        Behavior on x { SpringAnimation { spring: 2; damping: 0.3 } }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        onClicked: {
            root.checked = !root.checked
            if (root.onToggled) root.onToggled(root.checked)
        }
    }
}