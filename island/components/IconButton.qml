import QtQuick

Item {
    id: root
    property real ui: 1
    property string iconName: ""
    property bool active: false
    property string tooltip: ""

    function s(px) { return Math.round(px * ui) }

    width: s(36); height: s(36)

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: s(10)
        color: root.pressed ? "#1f1f1f" : (root.hovered || root.active ? "#1f1f1f" : "transparent")
        border.color: "#5a5a5a"
        border.width: s(1)

        Icon {
            id: icon
            anchors.centerIn: parent
            name: root.iconName
            size: s(18)
            color: root.active ? "#3b8bff" : "#ffffff"
        }
    }

    property bool hovered: false
    property bool pressed: false

    states: [
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges { target: root; scale: 0.96 }
        }
    ]

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onPressed: root.pressed = true
        onReleased: root.pressed = false
        onClicked: root.clicked()
    }

    signal clicked()
}
