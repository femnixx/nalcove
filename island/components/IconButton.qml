import QtQuick

Item {
    id: root
    width: 36
    height: 36

    property string iconName: ""
    property bool active: false
    property string tooltip: ""

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 10
        color: root.pressed ? "#1f1f1f" : (root.hovered || root.active ? "#1f1f1f" : "transparent")
        border.color: "#5a5a5a"
        border.width: 1

        Icon {
            id: icon
            anchors.centerIn: parent
            name: root.iconName
            size: 18
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
