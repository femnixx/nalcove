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

        // Theme object with all styling properties
        property QtObject theme: QtObject {
            readonly property color bg: "#f2101013"
            readonly property color card: "#0fffffff"
            readonly property color cardHi: "#1fffffff"
            readonly property color cardBorder: "#14ffffff"
            readonly property color fg: "#ffffff"
            readonly property color dim: "#9a9aa0"
            readonly property color faint: "#44ffffff"
            readonly property color accent: "#3b8bff"
            readonly property color accentSoft: "#2a3b8bff"
            readonly property color danger: "#ff453a"
            readonly property color dangerSoft: "#33ff453a"
            readonly property color success: "#34c759"
            readonly property color track: "#2a2a2e"
            readonly property color border: "#1fffffff"
            readonly property color overlay: "#000000"
            readonly property int s1: 4
            readonly property int s2: 8
            readonly property int s3: 12
            readonly property int s4: 16
            readonly property int s5: 24
            readonly property int rSm: 8
            readonly property int rMd: 12
            readonly property int rLg: 18
            readonly property int flareRadius: 12
            readonly property int expandedBottomRadius: 32
            readonly property int hoverBottomRadius: 24
            readonly property string fontFamily: "Inter, Roboto, Noto Sans, sans-serif"
            readonly property int tTitle: 16
            readonly property int tBody: 13
            readonly property int tSmall: 11
            readonly property int tCaption: 10
            readonly property int tClock: 36
            readonly property int dFast: 120
            readonly property int dBase: 180
            readonly property string easingOutCubic: "OutCubic"
            readonly property real springWidth: 3.5
            readonly property real dampingWidth: 0.35
            readonly property real epsilonWidth: 0.25
            readonly property real springHeight: 3.5
            readonly property real dampingHeight: 0.35
            readonly property real epsilonHeight: 0.25
            readonly property real springRadius: 3.0
            readonly property real dampingRadius: 0.4
            readonly property real epsilonRadius: 0.1
            readonly property int idleWidth: 200
            readonly property int idleHeight: 34
            readonly property int hoverWidth: 360
            readonly property int hoverHeight: 80
            readonly property int notifyWidth: 420
            readonly property int notifyHeight: 120
            readonly property int expandedWidth: 780
            readonly property int expandedHeight: 400
            readonly property int windowWidth: 780
            readonly property int windowHeight: 470
            readonly property int overshootMargin: 0
            readonly property int iconSm: 14
            readonly property int iconMd: 18
            readonly property int iconLg: 24
            readonly property int rowH: 36
            readonly property int controlH: 32
            readonly property int hoverDebounceMs: 150
            readonly property int contentFadeInMs: 180
            readonly property int contentFadeDelayMs: 80
            readonly property bool glass: true
        }

        property real currentWidth: triggerMode === "hotkey" ? theme.expandedWidth
            : (triggerMode === "notify" ? theme.notifyWidth
            : (triggerMode === "hover" ? theme.hoverWidth : (Media.isPlaying ? 270 : theme.idleWidth)))
        property real currentHeight: triggerMode === "hotkey" ? theme.expandedHeight
            : (triggerMode === "notify" ? theme.notifyHeight
            : (triggerMode === "hover" ? theme.hoverHeight : theme.idleHeight))
        property real currentBottomRadius: triggerMode === "closed" ? theme.rSm : theme.expandedBottomRadius

        Behavior on currentWidth {
            SpringAnimation { spring: theme.springWidth; damping: theme.dampingWidth; epsilon: theme.epsilonWidth }
        }
        Behavior on currentHeight {
            SpringAnimation { spring: theme.springHeight; damping: theme.dampingHeight; epsilon: theme.epsilonHeight }
        }
        Behavior on currentBottomRadius {
            SpringAnimation { spring: theme.springRadius; damping: theme.dampingRadius; epsilon: theme.epsilonRadius }
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
            property real flare: theme.flareRadius
            width: islandWindow.currentWidth
            height: islandWindow.currentHeight
            x: (parent.width - width) / 2
            y: theme.overshootMargin

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
                    strokeColor: theme.border
                    fillColor: islandWindow.triggerMode === "hotkey" ? theme.bg : "#000000"
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
                                    color: theme.fg
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
                            color: theme.fg
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: Media.artist
                            color: theme.dim
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
                            color: theme.fg
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

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: islandWindow.peekHovered = true
                        onExited: islandWindow.peekHovered = false
                        onClicked: islandWindow.triggerMode = "hotkey"
                    }

                    Loader {
                        anchors.fill: parent
                        active: islandWindow.peekNotification !== null
                        sourceComponent: notificationContent
                    }

                    Component {
                        id: notificationContent
                        Row {
                            anchors.fill: parent
                            anchors.margins: theme.s4
                            spacing: theme.s3

                            // App icon or image
                            Rectangle {
                                width: 64; height: 64
                                radius: theme.rMd
                                color: theme.card
                                border.color: theme.cardBorder
                                border.width: 1

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: islandWindow.peekNotification.image || islandWindow.peekNotification.appIcon || ""
                                    fillMode: Image.PreserveAspectFit
                                    visible: !!(islandWindow.peekNotification.image || islandWindow.peekNotification.appIcon)
                                }
                                Icon {
                                    anchors.centerIn: parent
                                    name: "bell"
                                    size: theme.iconLg
                                    color: theme.accent
                                    visible: !(islandWindow.peekNotification.image || islandWindow.peekNotification.appIcon)
                                }
                            }

                            // Text content
                            Column {
                                width: parent.width - 64 - theme.s3 - 48
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Row {
                                    spacing: theme.s2
                                    Text {
                                        text: islandWindow.peekNotification.appName || "Unknown"
                                        color: theme.dim
                                        font.pixelSize: theme.tSmall
                                        font.bold: true
                                        font.family: theme.fontFamily
                                    }
                                    Text {
                                        text: "·"
                                        color: theme.faint
                                        font.pixelSize: theme.tSmall
                                        font.family: theme.fontFamily
                                    }
                                    Text {
                                        text: islandWindow.peekNotification.urgency === 2 ? "Critical" : "Notification"
                                        color: islandWindow.peekNotification.urgency === 2 ? theme.danger : theme.dim
                                        font.pixelSize: theme.tSmall
                                        font.family: theme.fontFamily
                                    }
                                }

                                Text {
                                    text: islandWindow.peekNotification.summary || ""
                                    color: theme.fg
                                    font.pixelSize: theme.tBody
                                    font.bold: true
                                    font.family: theme.fontFamily
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: islandWindow.peekNotification.body || ""
                                    color: theme.dim
                                    font.pixelSize: theme.tSmall
                                    font.family: theme.fontFamily
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }

                                // Action buttons
                                Row {
                                    spacing: theme.s2
                                    visible: islandWindow.peekNotification.actions && islandWindow.peekNotification.actions.length > 0
                                    Repeater {
                                        model: islandWindow.peekNotification.actions
                                        delegate: Pill {
                                            text: modelData.label
                                            accent: true
                                            height: theme.controlH
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
                            NumberAnimation { duration: theme.dBase }
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
            interval: theme.hoverDebounceMs
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