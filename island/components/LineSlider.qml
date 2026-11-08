import QtQuick

Item {
    id: root
    property real value: 0
    property color fillColor: "white"
    signal moved(real v)
    implicitHeight: 20

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.track
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: 3
            color: root.fillColor
        }
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(1, root.value)) * (root.width - 16)
        width: 16; height: 16; radius: 8
        color: "white"
    }
    MouseArea {
        anchors.fill: parent
        onPressed: (m) => root.moved(Math.max(0, Math.min(1, m.x / width)))
        onPositionChanged: (m) => { if (pressed) root.moved(Math.max(0, Math.min(1, m.x / width))) }
    }
}
