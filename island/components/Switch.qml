import QtQuick


Rectangle {
    id: root
    property real ui: 1
    property bool checked: false
    property bool enabled: true
    property var onToggled: null

    function s(px) { return Math.round(px * ui) }

    width: s(44); height: s(26); radius: s(13)

    color: root.enabled ? (root.checked ? Style.accent : Style.track) : Style.track
    border.color: "transparent"
    border.width: 0

    Behavior on color { ColorAnimation { duration: Style.dFast; easing.type: Style.easingOutCubic } }

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
