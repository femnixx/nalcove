import QtQuick
import QtQuick.Effects

Item {
    id: root
    property string name: ""
    property color color: "#ffffff"
    property int size: 16

    width: size
    height: size

    Image {
        id: img
        source: "../icons/" + name + ".svg"
        anchors.fill: parent
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectFit
        mipmap: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        brightness: 1.0
        colorization: 1.0
        colorizationColor: root.color
    }
}