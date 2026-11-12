import QtQuick
import QtQuick.Shapes

// island/components/Glyph.qml - drawn media icons (no icon font needed)
// kind: "play" | "pause" | "next" | "prev"
Item {
    id: root
    property real ui: 1
    property string kind: "play"
    property color color: "white"

    function s(px) { return Math.round(px * ui) }

    implicitWidth: s(16)
    implicitHeight: s(16)

    // play triangle
    Shape {
        anchors.fill: parent
        visible: root.kind === "play"
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillColor: root.color
            startX: root.width * 0.15; startY: 0
            PathLine { x: root.width; y: root.height / 2 }
            PathLine { x: root.width * 0.15; y: root.height }
            PathLine { x: root.width * 0.15; y: 0 }
        }
    }

    // pause bars
    Item {
        anchors.fill: parent
        visible: root.kind === "pause"
        Rectangle { x: root.width * 0.15; width: root.width * 0.27; height: root.height; radius: 1.5 * ui; color: root.color }
        Rectangle { x: root.width * 0.58; width: root.width * 0.27; height: root.height; radius: 1.5 * ui; color: root.color }
    }

    // next: triangle + bar on the right
    Shape {
        anchors.fill: parent
        visible: root.kind === "next"
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillColor: root.color
            startX: 0; startY: 0
            PathLine { x: root.width * 0.72; y: root.height / 2 }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }
        }
    }
    Rectangle {
        visible: root.kind === "next"
        x: root.width * 0.8; width: root.width * 0.2; height: root.height; radius: 1 * ui; color: root.color
    }

    // prev: bar on the left + triangle pointing left
    Shape {
        anchors.fill: parent
        visible: root.kind === "prev"
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillColor: root.color
            startX: root.width; startY: 0
            PathLine { x: root.width * 0.28; y: root.height / 2 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: root.width; y: 0 }
        }
    }
    Rectangle {
        visible: root.kind === "prev"
        x: 0; width: root.width * 0.2; height: root.height; radius: 1 * ui; color: root.color
    }
}
