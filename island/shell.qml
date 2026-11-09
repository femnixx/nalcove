// island/shell.qml - Quickshell Dynamic Island (niri / any wlr-layer-shell compositor)
// Run with: qs -p ./island
// Toggle:   qs -p ./island ipc call island toggle

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import "services"
import "components"

ShellRoot {
    PanelWindow {
        id: islandWindow

        anchors { top: true; left: true; right: true }
        implicitHeight: 470
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "island"
        WlrLayershell.keyboardFocus: triggerMode === "hotkey"
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Close the island as soon as the user clicks outside it.
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            z: -1
            onClicked: {
                if (islandWindow.triggerMode === "hotkey")
                    islandWindow.triggerMode = "closed"
            }
        }

        // State machine: "closed" | "hover" | "hotkey"
        property string triggerMode: "closed"

        property real currentWidth: triggerMode === "hotkey" ? 780
            : (triggerMode === "hover" ? 360 : (Media.isPlaying ? 270 : 200))
        property real currentHeight: triggerMode === "hotkey" ? 400 : (triggerMode === "hover" ? 80 : 34)
        property real currentBottomRadius: triggerMode === "closed" ? 14 : 32

        Behavior on currentWidth {
            SpringAnimation { spring: 3.5; damping: 0.35; epsilon: 0.25 }
        }
        Behavior on currentHeight {
            SpringAnimation { spring: 3.5; damping: 0.35; epsilon: 0.25 }
        }
        Behavior on currentBottomRadius {
            SpringAnimation { spring: 3.0; damping: 0.4; epsilon: 0.1 }
        }

        // Only poll playback position while the island is open
        Binding {
            target: Media
            property: "tracking"
            value: islandWindow.triggerMode !== "closed"
        }

        // Clock only ticks while the dashboard is open
        Binding {
            target: Clock
            property: "active"
            value: islandWindow.triggerMode === "hotkey"
        }

        function toggleHotkey() {
            triggerMode = (triggerMode === "hotkey") ? "closed" : "hotkey"
        }

        mask: Region { item: hitbox }

        Item {
            id: hitbox
            x: islandShape.x - islandShape.flare - 2
            y: islandShape.y
            width: islandShape.width + 2 * islandShape.flare + 4
            height: islandShape.height + 2
        }

        Item {
            anchors.fill: parent
            focus: islandWindow.triggerMode === "hotkey"
            Keys.onEscapePressed: islandWindow.triggerMode = "closed"
        }

        Item {
            id: islandShape
            property real flare: 12
            width: islandWindow.currentWidth
            height: islandWindow.currentHeight
            x: (parent.width - width) / 2
            y: 0

            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    id: notchPath
                    property real w: islandShape.width
                    property real h: islandShape.height
                    property real f: islandShape.flare
                    property real r: Math.max(0, islandWindow.currentBottomRadius)

                    strokeWidth: islandWindow.triggerMode === "hotkey" ? 1 : 0
                    strokeColor: Theme.border
                    fillColor: islandWindow.triggerMode === "hotkey" ? Theme.islandFill : "#000000"
                    Behavior on fillColor { ColorAnimation { duration: 200 } }
                    startX: -f
                    startY: 0

                    PathLine { x: notchPath.w + notchPath.f; y: 0 }
                    PathArc {
                        x: notchPath.w; y: notchPath.f
                        radiusX: notchPath.f; radiusY: notchPath.f
                        direction: PathArc.Counterclockwise
                    }
                    PathLine { x: notchPath.w; y: notchPath.h - notchPath.r }
                    PathArc {
                        x: notchPath.w - notchPath.r; y: notchPath.h
                        radiusX: notchPath.r; radiusY: notchPath.r
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: notchPath.r; y: notchPath.h }
                    PathArc {
                        x: 0; y: notchPath.h - notchPath.r
                        radiusX: notchPath.r; radiusY: notchPath.r
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: notchPath.f }
                    PathArc {
                        x: -notchPath.f; y: 0
                        radiusX: notchPath.f; radiusY: notchPath.f
                        direction: PathArc.Counterclockwise
                    }
                }
            }

            // ---------- CONTENT ----------
            Item {
                id: content
                anchors.fill: parent
                clip: true

                // ===== Compact pill (closed + playing): art left, bars right =====
                Item {
                    id: compactPill
                    anchors.fill: parent
                    opacity: (islandWindow.triggerMode === "closed" && Media.isPlaying) ? 1 : 0
                    visible: opacity > 0.01
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    ClippingRectangle {
                        x: 14; y: 6
                        width: 22; height: 22
                        radius: 6
                        color: "#222222"
                        Image {
                            anchors.fill: parent
                            source: Media.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                    }

                    Row {
                        x: parent.width - 14 - width
                        y: 9
                        spacing: 3
                        Repeater {
                            model: 4
                            delegate: Item {
                                width: 3
                                height: 16
                                Rectangle {
                                    width: 3
                                    radius: 1.5
                                    color: "white"
                                    anchors.centerIn: parent
                                    height: 4 + index * 2
                                    SequentialAnimation on height {
                                        loops: Animation.Infinite
                                        running: compactPill.visible && Media.isPlaying
                                        NumberAnimation { to: 16; duration: 280 + index * 70; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 4; duration: 320 + index * 50; easing.type: Easing.InOutSine }
                                    }
                                }
                            }
                        }
                    }

                    // swipe left/right > 40 px = next / previous
                    DragHandler {
                        id: swipe
                        target: null
                        yAxis.enabled: false
                        property real lastDx: 0
                        onTranslationChanged: lastDx = translation.x
                        onActiveChanged: {
                            if (active) {
                                lastDx = 0
                            } else if (lastDx > 40) {
                                Media.previous()
                            } else if (lastDx < -40) {
                                Media.next()
                            }
                        }
                    }
                }

                // ===== Hover peek: art, title/artist, play/pause =====
                Item {
                    id: peekView
                    anchors.fill: parent
                    opacity: islandWindow.triggerMode === "hover" ? 1 : 0
                    visible: opacity > 0.01
                    Behavior on opacity {
                        SequentialAnimation {
                            PauseAnimation { duration: islandWindow.triggerMode === "hover" ? 80 : 0 }
                            NumberAnimation { duration: 150 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: islandWindow.triggerMode = "hotkey"
                    }

                    ClippingRectangle {
                        x: 14; y: 12
                        width: 56; height: 56
                        radius: 10
                        color: "#222222"
                        Image {
                            anchors.fill: parent
                            source: Media.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                    }

                    Column {
                        x: 82; y: 22
                        width: parent.width - 82 - 64
                        spacing: 3
                        Text {
                            width: parent.width
                            text: Media.hasPlayer ? Media.title : "Nothing playing"
                            color: "white"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: Media.artist
                            color: "#9a9a9f"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        x: parent.width - 52; y: 22
                        width: 36; height: 36
                        visible: Media.hasPlayer
                        Glyph {
                            anchors.centerIn: parent
                            width: 16; height: 16
                            kind: Media.isPlaying ? "pause" : "play"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Media.playPause()
                        }
                    }
                }

                // ===== Expanded (hotkey): tabbed dashboard =====
                Dashboard {
                    id: fullView
                    anchors.fill: parent
                    active: islandWindow.triggerMode === "hotkey"
                    opacity: active ? 1 : 0
                    visible: opacity > 0.01
                    Behavior on opacity {
                        SequentialAnimation {
                            PauseAnimation { duration: fullView.active ? 100 : 0 }
                            NumberAnimation { duration: 180 }
                        }
                    }
                }
            }

            // Hover peek (disabled while locked open)
            HoverHandler {
                enabled: islandWindow.triggerMode !== "hotkey"
                onHoveredChanged: {
                    if (hovered) {
                        hoverDebounce.stop()
                        if (islandWindow.triggerMode === "closed")
                            islandWindow.triggerMode = "hover"
                    } else if (islandWindow.triggerMode === "hover") {
                        hoverDebounce.restart()
                    }
                }
            }
        }

        Timer {
            id: hoverDebounce
            interval: 150
            onTriggered: {
                if (islandWindow.triggerMode === "hover")
                    islandWindow.triggerMode = "closed"
            }
        }

        IpcHandler {
            target: "island"
            function toggle(): void { islandWindow.toggleHotkey() }
        }
    }
}
