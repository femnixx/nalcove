import QtQuick
import qs.components as Theme
import QtQuick.Layouts
import ".." 1.0 as Theme

Rectangle {
    id: root
    Layout.fillWidth: true
    radius: Theme.rLg
    color: Theme.card
    border.color: Theme.cardBorder
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
            PropertyChanges { target: root; color: Theme.cardHi }
        },
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges { target: root; color: Theme.cardHi; opacity: 0.9 }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "hovered"
            ColorAnimation { properties: "color"; duration: Theme.dFast; easing.type: Theme.easingOutCubic }
        },
        Transition {
            from: "hovered"; to: ""
            ColorAnimation { properties: "color"; duration: Theme.dFast; easing.type: Theme.easingOutCubic }
        },
        Transition {
            from: ""; to: "pressed"
            PropertyAnimation { properties: "opacity"; duration: Theme.dFast; easing.type: Theme.easingOutCubic }
        },
        Transition {
            from: "pressed"; to: ""
            PropertyAnimation { properties: "opacity"; duration: Theme.dFast; easing.type: Theme.easingOutCubic }
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