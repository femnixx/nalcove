import QtQuick
import QtQuick.Controls

Slider {
    id: s
    property color fill: "#3b8bff"
    property bool bold: false
    implicitHeight: bold ? 24 : 18

    background: Rectangle {
        x: s.leftPadding; y: s.topPadding + s.availableHeight / 2 - height / 2
        width: s.availableWidth; height: s.bold ? 6 : 5; radius: 3; color: s.bold ? "#4a4a4a" : "#22ffffff"
        Rectangle { width: s.visualPosition * parent.width; height: parent.height; radius: 3; color: s.bold ? "#ffffff" : s.fill }
    }
    handle: Rectangle {
        x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: s.bold ? 22 : 14; height: s.bold ? 22 : 14; radius: s.bold ? 11 : 7; color: "#ffffff"
        border.color: s.bold ? "#5a5a5a" : "transparent"; border.width: s.bold ? 1 : 0
    }
}
