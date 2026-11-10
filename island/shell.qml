// island/shell.qml - Quickshell Dynamic Island (niri / any wlr-layer-shell compositor)
// Run with: qs -p ./island
// Toggle:   qs -p ./island ipc call island toggle
//@ pragma IconTheme "Papirus-Dark"

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import "services"
import "components"

ShellRoot {
    PanelWindow {
        id: islandWindow

        anchors { top: true; left: true; right: true }
        implicitHeight: Theme.windowHeight
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
                // Ignore outside clicks while the dashboard is pinned open.
                if (islandWindow.triggerMode === "hotkey" && !fullView.pinned)
                    islandWindow.triggerMode = "closed"
            }
        }

        // State machine: "closed" | "hover" | "notify" | "hotkey"
        property string triggerMode: "closed"

        // Notification peek state
        property var peekNotification: null
        property bool peekHovered: false

        property real currentWidth: triggerMode === "hotkey" ? Theme.expandedWidth
            : (triggerMode === "notify" ? Theme.notifyWidth
            : (triggerMode === "hover" ? Theme.hoverWidth : (Media.isPlaying ? 270 : Theme.idleWidth)))
        property real currentHeight: triggerMode === "hotkey" ? Theme.expandedHeight
            : (triggerMode === "notify" ? Theme.notifyHeight
            : (triggerMode === "hover" ? Theme.hoverHeight : Theme.idleHeight))
        property real currentBottomRadius: triggerMode === "closed" ? Theme.rSm : Theme.expandedBottomRadius

        Behavior on currentWidth {
            SpringAnimation { spring: Theme.springWidth; damping: Theme.dampingWidth; epsilon: Theme.epsilonWidth }
        }
        Behavior on currentHeight {
            SpringAnimation { spring: Theme.springHeight; damping: Theme.dampingHeight; epsilon: Theme.epsilonHeight }
        }
        Behavior on currentBottomRadius {
            SpringAnimation { spring: Theme.springRadius; damping: Theme.dampingRadius; epsilon: Theme.epsilonRadius }
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
            // While pinned the island stays locked open: toggle unpins first, then closes.
            if (fullView.pinned) {
                fullView.pinned = false
                islandWindow.triggerMode = "closed"
                return
            }
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
            Keys.onEscapePressed: { if (!fullView.pinned) islandWindow.triggerMode = "closed" }
        }

        Item {
            id: islandShape
            property real flare: Theme.flareRadius
            width: islandWindow.currentWidth
            height: islandWindow.currentHeight
            x: (parent.width - width) / 2
            y: Theme.overshootMargin

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
                    fillColor: islandWindow.triggerMode === "hotkey" ? Theme.bg : "#000000"
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
                                    color: Theme.fg
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
                            color: Theme.fg
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: Media.artist
                            color: Theme.dim
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
                            color: Theme.fg
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Media.playPause()
                        }
                    }
                }

                // ===== Notification peek =====
                Item {
                    id: notifyView
                    anchors.fill: parent
                    opacity: islandWindow.triggerMode === "notify" ? 1 : 0
                    visible: opacity > 0.01 && islandWindow.peekNotification !== null
                    Behavior on opacity {
                        SequentialAnimation {
                            PauseAnimation { duration: 0 }
                            NumberAnimation { duration: 150 }
                        }
                    }

                    property var n: islandWindow.peekNotification

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: islandWindow.peekHovered = true
                        onExited: islandWindow.peekHovered = false
                        onClicked: islandWindow.triggerMode = "hotkey"
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.s4
                        spacing: Theme.s3

                        // App icon or image
                        Rectangle {
                            width: 64; height: 64
                            radius: Theme.rMd
                            color: Theme.card
                            border.color: Theme.cardBorder
                            border.width: 1

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                source: n.image || n.appIcon || ""
                                fillMode: Image.PreserveAspectFit
                                visible: !!(n.image || n.appIcon)
                            }
                            Icon {
                                anchors.centerIn: parent
                                name: "bell"
                                size: Theme.iconLg
                                color: Theme.accent
                                visible: !(n.image || n.appIcon)
                            }
                        }

                        // Text content
                        Column {
                            width: parent.width - 64 - Theme.s3 - 48
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                spacing: Theme.s2
                                Text {
                                    text: n.appName || "Unknown"
                                    color: Theme.dim
                                    font.pixelSize: Theme.tSmall
                                    font.bold: true
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: "·"
                                    color: Theme.faint
                                    font.pixelSize: Theme.tSmall
                                    font.family: Theme.fontFamily
                                }
                                Text {
                                    text: n.urgency === 2 ? "Critical" : "Notification"
                                    color: n.urgency === 2 ? Theme.danger : Theme.dim
                                    font.pixelSize: Theme.tSmall
                                    font.family: Theme.fontFamily
                                }
                            }

                            Text {
                                text: n.summary || ""
                                color: Theme.fg
                                font.pixelSize: Theme.tBody
                                font.bold: true
                                font.family: Theme.fontFamily
                                elide: Text.ElideRight
                            }

                            Text {
                                text: n.body || ""
                                color: Theme.dim
                                font.pixelSize: Theme.tSmall
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            // Action buttons
                            Row {
                                spacing: Theme.s2
                                visible: n.actions && n.actions.length > 0
                                Repeater {
                                    model: n.actions
                                    delegate: Pill {
                                        text: modelData.label
                                        accent: true
                                        height: Theme.controlH
                                        onClicked: {
                                            modelData.invoke()
                                            islandWindow.peekNotification.dismiss()
                                            islandWindow.triggerMode = "closed"
                                        }
                                    }
                                }
                            }
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
                            NumberAnimation { duration: Theme.dBase }
                        }
                    }
                }
            }
        }

        // Hover peek (disabled while locked open or in notify mode)
        HoverHandler {
            enabled: islandWindow.triggerMode === "closed" || islandWindow.triggerMode === "hover"
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

        Timer {
            id: hoverDebounce
            interval: Theme.hoverDebounceMs
            onTriggered: {
                if (islandWindow.triggerMode === "hover")
                    islandWindow.triggerMode = "closed"
            }
        }

        // Notification peek timeout timer
        Timer {
            id: notifyTimeout
            interval: 5000
            repeat: false
            onTriggered: {
                if (islandWindow.triggerMode === "notify" && !islandWindow.peekHovered) {
                    islandWindow.triggerMode = "closed"
                    islandWindow.peekNotification = null
                }
            }
        }

        // Listen for notifications
        Connections {
            target: Notifications
            function onReceived(n) {
                if (islandWindow.triggerMode === "hotkey") return
                if (Notifications.dnd) return

                islandWindow.peekNotification = n
                islandWindow.triggerMode = "notify"
                notifyTimeout.interval = n.expireTimeout > 0 ? n.expireTimeout : 5000
                notifyTimeout.restart()
            }
        }

        IpcHandler {
            target: "island"
            function toggle(): void { islandWindow.toggleHotkey() }
        }

        // Global keybind: Ctrl+Alt+Space toggles the island open/closed.
        Shortcut {
            sequence: "Ctrl+Alt+Space"
            onActivated: {
                if (islandWindow.triggerMode === "closed")
                    islandWindow.triggerMode = "hotkey"
                else
                    islandWindow.triggerMode = "closed"
            }
        }
    }
}