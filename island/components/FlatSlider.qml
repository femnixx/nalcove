import QtQuick
import QtQuick.Controls

Slider {
    id: slider
    property real ui: 1
    property color fill: "#3b8bff"
    property bool bold: false

    function s(px) { return Math.round(px * ui) }

    implicitHeight: bold ? s(24) : s(18)

    background: Rectangle {
        x: slider.leftPadding; y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth; height: bold ? s(6) : s(5); radius: s(3); color: bold ? "#4a4a4a" : "#22ffffff"
        Rectangle { width: slider.visualPosition * parent.width; height: parent.height; radius: s(3); color: bold ? "#ffffff" : fill }
    }
    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: bold ? s(22) : s(14); height: bold ? s(22) : s(14); radius: bold ? s(11) : s(7); color: "#ffffff"
        border.color: bold ? "#5a5a5a" : "transparent"; border.width: bold ? s(1) : 0
    }
}
