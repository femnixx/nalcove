// island/IslandShape.qml - Notch-shaped component using QtQuick.Shapes
// Concave top flares, convex bottom corners, flush top edge, black fill

import QtQuick 2.15
import QtQuick.Shapes 2.15

Item {
    id: islandShapeRoot

    property int width: Theme.idleWidth   // 200 idle
    property int height: Theme.idleHeight // 34 idle
    property int bottomRadius: Theme.idleBottomRadius  // 14 idle
    property int flare: Theme.flareRadius // 12

    Shape {
        id: shape

        // The Shape's width/height come from the parent Item
        // No explicit width/height needed; Shape adapts

        layer.enabled: true
        layer.smooth: true

        ShapePath {
            id: shapePath
            strokeWidth: 0
            fillColor: Theme.islandFill

            // Start at top-left: begin at the leftmost point of the top edge
            // For a centered 200-wide shape, the shape starts at x=0 (left edge)
            PathLine { x: 0; y: 0 }

            // Top-left concave flare: curve outward (below top edge)
            // The flare bows outward - concave from the shape's perspective
            PathQuad {
                x: -flare
                y: flare
                controlX: -flare * 0.4
                controlY: flare * 0.3
            }

            // Left side down, approaching bottom-left corner
            PathLine { x: 0; y: parent.height - bottomRadius }

            // Bottom-left convex corner (rounded)
            PathArc {
                x: bottomRadius
                y: parent.height
                radiusX: bottomRadius
                radiusY: bottomRadius
                useLargeArc: false
                direction: PathArc.Clockwise
            }

            // Bottom edge
            PathLine { x: parent.width - bottomRadius; y: parent.height }

            // Bottom-right convex corner (rounded)
            PathArc {
                x: parent.width
                y: parent.height - bottomRadius
                radiusX: bottomRadius
                radiusY: bottomRadius
                useLargeArc: false
                direction: PathArc.Clockwise
            }

            // Right side up
            PathLine { x: parent.width; y: flare }

            // Top-right concave flare
            PathQuad {
                x: parent.width + flare
                y: flare
                controlX: parent.width + flare * 0.4
                controlY: flare * 0.3
            }

            // Close at top edge
            PathLine { x: 0; y: 0 }
        }
    }
}