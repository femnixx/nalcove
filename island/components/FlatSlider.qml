import QtQuick
import qs.components 1.0
import QtQuick.Controls


Slider {
    id: s
    property color fill: Theme.accent
    implicitHeight: 18

    background: Rectangle {
        x: s.leftPadding; y: s.topPadding + s.availableHeight / 2 - height / 2
        width: s.availableWidth; height: 5; radius: 3; color: Theme.track
        Rectangle { width: s.visualPosition * parent.width; height: parent.height; radius: 3; color: s.fill }
    }
    handle: Rectangle {
        x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: 14; height: 14; radius: 7; color: Theme.fg
    }
}