// island/IslandShape.qml - Notch shape: concave top flares, convex bottom corners, flush top edge
// All coordinates come from THIS item's width/height (root.width / root.height),
// never from `parent`, which inside a ShapePath resolves to the window.

import QtQuick 2.15
import QtQuick.Shapes 2.15
import qs.components 1.0

Item {
    id: root

    property real bottomRadius: Style.idleBottomRadius
    property real flare: Style.flareRadius
    property color fillColor: Style.islandFill

    // Clamped so the radii can never exceed the shape (the idle pill is small)
    readonly property real r: Math.max(0, Math.min(bottomRadius, width / 2, height))
    readonly property real f: Math.max(0, Math.min(flare, height))

    Shape {
        // No layer.enabled: it allocates an offscreen texture that is re-rendered every frame.
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer   // needs Qt >= 6.6; delete this line on older Qt

        ShapePath {
            strokeWidth: 0
            fillColor: root.fillColor

            // start on the top edge, left of the notch
            startX: -root.f
            startY: 0

            // top-left concave flare: curves from the top edge into the left wall
            PathQuad { x: 0; y: root.f; controlX: 0; controlY: 0 }

            // left wall
            PathLine { x: 0; y: root.height - root.r }

            // bottom-left convex corner
            PathArc {
                x: root.r; y: root.height
                radiusX: root.r; radiusY: root.r
                direction: PathArc.Counterclockwise
            }

            // bottom edge
            PathLine { x: root.width - root.r; y: root.height }

            // bottom-right convex corner
            PathArc {
                x: root.width; y: root.height - root.r
                radiusX: root.r; radiusY: root.r
                direction: PathArc.Counterclockwise
            }

            // right wall
            PathLine { x: root.width; y: root.f }

            // top-right concave flare
            PathQuad { x: root.width + root.f; y: 0; controlX: root.width; controlY: 0 }

            // close along the top edge
            PathLine { x: -root.f; y: 0 }
        }
    }
}
