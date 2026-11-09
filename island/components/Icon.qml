import QtQuick
import QtQuick.Effects

// island/components/Icon.qml - recolored SVG icon from island/icons/*.svg
// Usage: Icon { name: "home"; color: Theme.accent; size: 20 }
Item {
    id: root
    property string name: ""
    property color color: Theme.fg
    property int size: 18
    width: size
    height: size

    Image {
        id: img
        visible: false
        source: "../icons/" + name + ".svg"
        sourceSize: Qt.size(size * 2, size * 2)
        asynchronous: true
    }

    MultiEffect {
        source: img
        anchors.fill: parent
        colorization: 1.0
        colorizationColor: root.color
    }
}