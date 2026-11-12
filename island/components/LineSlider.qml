import QtQuick

Item {
    id: root
    property real ui: 1
    property real value: 0
    property color fillColor: "white"
    signal moved(real v)

    function s(px) { return Math.round(px * ui) }

    implicitHeight: s(20)

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: s(6)
        radius: s(3)
        color: Style.track
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: s(3)
            color: root.fillColor
        }
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(1, root.value)) * (root.width - s(16))
        width: s(16); height: s(16); radius: s(8)
        color: "white"
    }
    MouseArea {
        anchors.fill: parent
        onPressed: (m) => root.moved(Math.max(0, Math.min(1, m.x / width)))
        onPositionChanged: (m) => { if (pressed) root.moved(Math.max(0, Math.min(1, m.x / width))) }
    }
}
