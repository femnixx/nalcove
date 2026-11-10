import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    height: Theme.controlH
    radius: Theme.rMd
    clip: true

    property string text: ""
    property string icon: ""
    property bool accent: false
    property bool danger: false
    property bool busy: false
    property bool enabled: true
    property bool iconOnly: false
    property string tooltip: ""
    property var onClicked: null

    implicitWidth: content.implicitWidth + (root.iconOnly ? 0 : Theme.s4 * 2)

    property color bgColor: root.enabled
        ? (root.accent ? Theme.accent : (root.danger ? Theme.danger : Theme.cardHi))
        : Theme.track

    color: bgColor

    border.color: root.accent || root.danger ? "transparent" : Theme.cardBorder
    border.width: root.accent || root.danger ? 0 : 1

    Behavior on bgColor { ColorAnimation { duration: Theme.dFast; easing.type: Theme.easingOutCubic } }

    property real _opacity: root.enabled ? 1.0 : 0.5

    Row {
        id: content
        anchors.centerIn: parent
        spacing: root.text && root.icon ? Theme.s2 : 0

        Loader {
            sourceComponent: root.icon ? IconComponent : null
            active: !!root.icon
        }

        Text {
            id: label
            text: root.text
            visible: !root.iconOnly
            font.pixelSize: Theme.tBody
            font.bold: root.accent
            font.family: Theme.fontFamily
            color: root.accent || root.danger ? "#ffffff" : Theme.fg
            verticalAlignment: Text.AlignVCenter
        }
    }

    Component {
        id: IconComponent
        Icon {
            name: root.icon
            size: Theme.iconMd
            color: root.accent || root.danger ? "#ffffff" : Theme.fg
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && !root.busy
        onClicked: { if (root.onClicked) root.onClicked() }
        onPressed: root.scale = 0.98
        onReleased: root.scale = 1.0
    }

    Behavior on scale { SpringAnimation { spring: 2; damping: 0.3 } }

    ToolTip {
        text: root.tooltip
        visible: root.iconOnly && root.tooltip !== "" && root.hovered
        delay: 500
    }
}