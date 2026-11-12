// island/IslandWindow.qml - Responsive dynamic-notch window
//
// Responsive model:
//   * `ui` is one scale factor per screen (1.0 at 1920x1080), clamped to 0.75 .. 1.6.
//   * Every notch size (idle / hover / expanded) is Style.* * ui, then clamped so it can
//     never be bigger than the screen minus a margin.
//   * The window height is derived from the clamped expanded size, never from a separate
//     constant, so it can't drift out of sync with the notch.
//   * The dashboard gets the clamped expanded size as a FIXED size. The animated notch
//     just reveals it (clip), so layouts and breakpoints inside the dashboard don't
//     re-run on every frame of the spring.

import QtQuick 2.15
import Quickshell
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import qs.components 1.0
import "services" as Services

PanelWindow {
    id: islandWindow

    // ===== Window rules =====
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "island"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Full-width top strip; the notch centers itself inside it and only the notch
    // receives input (see `mask`). Height = expanded notch + room for spring overshoot.
    anchors { top: true; left: true; right: true }
    implicitHeight: screen ? Math.min(expH + s(40), screen.height) : expH + s(40)

    // ===== Scale factor (per screen) =====
    // Reference design: 1920x1080. Qt already applies Wayland fractional scaling, so we use
    // logical screen size and never multiply by devicePixelRatio.
    readonly property real ui: screen
        ? Math.max(0.75, Math.min(1.6,
            Math.min(screen.width / 1920, screen.height / 1080)))
        : 1.0

    // Rounds to whole pixels (borders, radii, icon sizes). Animated values use `* ui`.
    function s(px) { return Math.round(px * ui) }

    // ===== Clamped sizes =====
    readonly property real edge: s(24)
    readonly property real availW: screen ? screen.width - 2 * edge : 4000
    readonly property real availH: screen ? screen.height - 2 * edge : 4000

    readonly property real expW: Math.min(Style.expandedWidth * ui, availW)
    readonly property real expH: Math.min(Style.expandedHeight * ui, availH)
    readonly property real hovW: Math.min(Style.hoverWidth * ui, expW)
    readonly property real hovH: Math.min(Style.hoverHeight * ui, expH)
    readonly property real idlW: Math.min(Style.idleWidth * ui, hovW)
    readonly property real idlH: Math.min(Style.idleHeight * ui, hovH)

    // ===== State machine =====
    property string triggerMode: "closed"   // "closed" | "hover" | "hotkey"

    // Target sizes for the current state (real, so springs interpolate fractions)
    property real currentWidth: triggerMode === "hotkey" ? expW
        : (triggerMode === "hover" ? hovW : idlW)
    property real currentHeight: triggerMode === "hotkey" ? expH
        : (triggerMode === "hover" ? hovH : idlH)
    property real currentBottomRadius: triggerMode === "hotkey" ? Style.expandedBottomRadius * ui
        : (triggerMode === "hover" ? Style.hoverBottomRadius * ui : Style.idleBottomRadius * ui)

    // Spring animations (spring / damping / epsilon values come from Style, untouched)
    Behavior on currentWidth {
        SpringAnimation {
            spring: Style.springWidth
            damping: Style.dampingWidth
            epsilon: Style.epsilonWidth
        }
    }
    Behavior on currentHeight {
        SpringAnimation {
            spring: Style.springHeight
            damping: Style.dampingHeight
            epsilon: Style.epsilonHeight
        }
    }
    Behavior on currentBottomRadius {
        SpringAnimation {
            spring: Style.springRadius
            damping: Style.dampingRadius
            epsilon: Style.epsilonRadius
        }
    }

    // Only poll playback position while the island is open
    Binding {
        target: Services.Media
        property: "tracking"
        value: islandWindow.triggerMode !== "closed"
    }

    // Clock only ticks while the dashboard is open
    Binding {
        target: Clock
        property: "active"
        value: islandWindow.triggerMode === "hotkey"
    }

    // ===== Input mask: only the notch (plus its flares) receives input =====
    mask: Region {
        item: hitbox
    }

    Item {
        id: hitbox
        x: islandShape.x - islandShape.flare - 2
        y: islandShape.y
        width: islandShape.width + 2 * islandShape.flare + 4
        height: islandShape.height + 2
    }

    // ===== Notch shape, centered in the window =====
    IslandShape {
        id: islandShape
        width: islandWindow.currentWidth
        height: islandWindow.currentHeight
        bottomRadius: islandWindow.currentBottomRadius
        flare: s(Style.flareRadius)
        x: (parent.width - width) / 2
        y: s(Style.overshootMargin)
        fillColor: "#f2101012"

        // ===== CONTENT: clipped to the animated notch =====
        Item {
            id: content
            anchors.fill: parent
            clip: true
            focus: islandWindow.triggerMode === "hotkey"

            // Escape closes the island
            Keys.enabled: islandWindow.triggerMode === "hotkey"
            Keys.onPressed: {
                if (event.key === Qt.Key_Escape)
                    islandWindow.triggerMode = "closed"
            }

            // ----- Compact pill (closed + playing): art left, bars right -----
            Item {
                id: compactPill
                anchors.fill: parent
                opacity: (islandWindow.triggerMode === "closed" && Services.Media.isPlaying) ? 1 : 0
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 150 } }

                ClippingRectangle {
                    x: s(14); y: (parent.height - height) / 2
                    width: s(22); height: s(22)
                    radius: s(6)
                    color: "#222222"
                    Image {
                        anchors.fill: parent
                        source: Services.Media.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(s(44), s(44))
                    }
                }

                Row {
                    x: parent.width - s(14) - width
                    y: (parent.height - height) / 2
                    spacing: s(3)
                    Repeater {
                        model: 4
                        delegate: Item {
                            width: s(3)
                            height: 16 * ui
                            Rectangle {
                                width: s(3)
                                radius: 1.5 * ui
                                color: Style.fg
                                anchors.centerIn: parent
                                height: (4 + index * 2) * ui
                                SequentialAnimation on height {
                                    loops: Animation.Infinite
                                    running: compactPill.visible && Services.Media.isPlaying
                                    NumberAnimation { to: 16 * ui; duration: 280 + index * 70; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: (4 + index * 2) * ui; duration: 320 + index * 50; easing.type: Easing.InOutSine }
                                }
                            }
                        }
                    }
                }

                // swipe left/right > 40 px = next / previous (input threshold, unscaled)
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
                            Services.Media.previous()
                        } else if (lastDx < -40) {
                            Services.Media.next()
                        }
                    }
                }
            }

            // ----- Hover peek: art, title/artist, play/pause -----
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
                    x: s(14); y: (parent.height - height) / 2
                    width: s(56); height: s(56)
                    radius: s(10)
                    color: "#222222"
                    Image {
                        anchors.fill: parent
                        source: Services.Media.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(s(112), s(112))
                    }
                }

                Column {
                    x: s(82)
                    y: (parent.height - height) / 2
                    width: Math.max(0, parent.width - s(82) - s(64))
                    spacing: s(3)
                    Text {
                        width: parent.width
                        text: Services.Media.hasPlayer ? Services.Media.title : "Nothing playing"
                        color: Style.fg
                        font.pixelSize: 13 * ui
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: Services.Media.artist
                        color: Style.dim
                        font.pixelSize: 11 * ui
                        elide: Text.ElideRight
                    }
                }

                Item {
                    x: parent.width - s(52)
                    y: (parent.height - height) / 2
                    width: s(36); height: s(36)
                    visible: Services.Media.hasPlayer
                    Glyph {
                        anchors.centerIn: parent
                        width: s(16); height: s(16)
                        kind: Services.Media.isPlaying ? "pause" : "play"
                        color: Style.fg
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Services.Media.playPause()
                    }
                }
            }

            // ----- Expanded: tabbed dashboard at a FIXED size -----
            // The notch's clip reveals it as it grows, so nothing inside re-lays out per frame.
            Dashboard {
                id: fullView
                width: islandWindow.expW
                height: islandWindow.expH
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                ui: islandWindow.ui
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
    }

    // ===== Hover peek (open on hover, close after a short debounce) =====
    HoverHandler {
        id: hoverHandler
        enabled: islandWindow.triggerMode !== "hotkey"
        onHoveredChanged: {
            if (hovered) {
                hoverDebounceTimer.stop()
                if (islandWindow.triggerMode === "closed")
                    islandWindow.triggerMode = "hover"
            } else if (islandWindow.triggerMode === "hover") {
                hoverDebounceTimer.restart()
            }
        }
    }

    Timer {
        id: hoverDebounceTimer
        interval: Style.hoverDebounceMs
        repeat: false
        onTriggered: {
            if (islandWindow.triggerMode === "hover")
                islandWindow.triggerMode = "closed"
        }
    }

    // ===== Toggling =====
    function toggleHotkey() {
        triggerMode = (triggerMode === "hotkey") ? "closed" : "hotkey"
    }

    // Hyprland only (no-op with a warning on niri)
    GlobalShortcut {
        id: islandShortcut
        appid: "island"
        name: "toggle"
        onPressed: islandWindow.toggleHotkey()
    }

    // Any compositor: qs -p ./island ipc call island toggle
    IpcHandler {
        id: islandIpc
        target: "island"

        function toggle() {
            islandWindow.toggleHotkey()
        }
    }

    // Only fires while the island has keyboard focus
    Shortcut {
        sequence: "Ctrl+Alt+Space"
        onActivated: islandWindow.toggleHotkey()
    }

    // ===== Keyboard focus only while open =====
    function updateKeyboardFocus() {
        WlrLayershell.keyboardFocus = (triggerMode === "hotkey")
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None
    }

    Component.onCompleted: updateKeyboardFocus()
    onTriggerModeChanged: updateKeyboardFocus()
}
