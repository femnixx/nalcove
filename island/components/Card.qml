import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 200
    implicitHeight: 200
    radius: root.cardRadius
    color: root.cardFill
    border.color: root.cardBorderColor
    border.width: 1
    clip: true

    property color cardFill: "#141414"
    property color cardBorderColor: "#3a3a3a"
    property int cardRadius: 14
    property int cardPadding: 16

    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    property bool hoverEnabled: true
    property bool pressed: false
    property bool hovered: false

    states: [
        State {
            name: "hovered"
            when: root.hoverEnabled && root.hovered && !root.pressed
            PropertyChanges { target: root; color: "#1fffffff" }
        },
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges { target: root; color: "#1fffffff"; opacity: 0.9 }
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
