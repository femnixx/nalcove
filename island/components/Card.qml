import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    Layout.fillWidth: true
    radius: Style.rLg
    color: Style.card
    border.color: Style.cardBorder
    border.width: 1

    property alias content: contentItem.children
    property bool hoverEnabled: true
    property bool pressed: false
    property bool hovered: false

    Column {
        id: contentItem
        anchors.fill: parent
    }

    states: [
        State {
            name: "hovered"
            when: root.hoverEnabled && root.hovered && !root.pressed
            PropertyChanges { target: root; color: Style.cardHi }
        },
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges { target: root; color: Style.cardHi; opacity: 0.9 }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "hovered"
            ColorAnimation { properties: "color"; duration: 120; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "hovered"; to: ""
            ColorAnimation { properties: "color"; duration: 120; easing.type: Easing.OutCubic }
        },
        Transition {
            from: ""; to: "pressed"
            PropertyAnimation { properties: "opacity"; duration: 120; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "pressed"; to: ""
            PropertyAnimation { properties: "opacity"; duration: 120; easing.type: Easing.OutCubic }
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: root.hoverEnabled
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onPressed: root.pressed = true
        onReleased: root.pressed = false
    }
}