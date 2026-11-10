// island/IslandWindow.qml - Window wrapper with notch shape
// Phase 1: transparent top-anchored layer-shell window drawing the notch shape

import QtQuick 2.15
import Quickshell._Window
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Io
import qs.components 1.0 as Style

PanelWindow {
    id: islandWindow

    // Window rules
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "island"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Fixed size: expanded + overshoot margin, never resize during animation
    width: Style.windowWidth
    height: Style.windowHeight

    // Anchor flush to top edge, centered horizontally
    anchors.top: true
    anchors.left: parent.left + (parent.width - width) / 2
    anchors.right: parent.right - (parent.width - width) / 2

    // State machine
    property string triggerMode: "closed"   // "closed" | "hover" | "hotkey"

    // Hitbox region tracks the island's current animated rect
    property item hitbox: islandShape

    // Derived size from state
    property int currentWidth: {
        if (triggerMode === "hotkey") Style.expandedWidth
        else if (triggerMode === "hover") Style.hoverWidth
        else Style.idleWidth
    }
    property int currentHeight: {
        if (triggerMode === "hotkey") Style.expandedHeight
        else if (triggerMode === "hover") Style.hoverHeight
        else Style.idleHeight
    }
    property int currentBottomRadius: {
        if (triggerMode === "hotkey") Style.expandedBottomRadius
        else if (triggerMode === "hover") Style.hoverBottomRadius
        else Style.idleBottomRadius
    }

    // Spring animations on size properties
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

    // Notch shape centered at top of window
    IslandShape {
        id: islandShape
        width: currentWidth
        height: currentHeight
        bottomRadius: currentBottomRadius
        flare: Style.flareRadius

        // Center at top of window, offset by overshoot margin
        x: (parent.width - width) / 2
        y: Style.overshootMargin
    }

    // Hitbox tracks current animated rect + padding
    Item {
        id: hitboxItem
        x: islandShape.x
        y: islandShape.y
        width: islandShape.width + 4
        height: islandShape.height + 4
    }

    // Input mask: only the island receives input
    mask: Region {
        item: hitboxItem
    }

    // HoverHandler for peek
    HoverHandler {
        id: hoverHandler
        target: islandShape
        hoverEnabled: triggerMode !== "hotkey"

        onEntered: {
            if (triggerMode === "closed")
                triggerMode = "hover"
        }

        onExited: {
            if (triggerMode === "hover") {
                hoverDebounceTimer.restart()
            }
        }
    }

    Timer {
        id: hoverDebounceTimer
        interval: Style.hoverDebounceMs
        repeat: false
        onTriggered: {
            if (triggerMode === "hover")
                triggerMode = "closed"
        }
    }

    // GlobalShortcut for Hyprland hotkey toggle
    GlobalShortcut {
        id: islandShortcut
        appId: "island"
        name: "toggle"
        activated: toggleHotkey()
    }

    // IPC handler for all other compositors: qs ipc call island toggle
    IpcHandler {
        id: islandIpc
        target: "island"

        function toggle() {
            toggleHotkey()
        }
    }

    function toggleHotkey() {
        if (triggerMode === "hotkey") {
            triggerMode = "closed"
        } else {
            triggerMode = "hotkey"
        }
    }

    // Escape closes hotkey mode
    Keys.enabled: triggerMode === "hotkey"
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape)
            triggerMode = "closed"
    }

    // Keyboard focus only in hotkey mode
    Component.onCompleted: {
        updateKeyboardFocus()
    }

    function updateKeyboardFocus() {
        WlrLayershell.keyboardFocus = (triggerMode === "hotkey")
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None
    }

    onTriggerModeChanged: updateKeyboardFocus()

    // Stub: expanded content placeholder
    Item {
        id: expandedContent
        visible: triggerMode === "hotkey"
        opacity: triggerMode === "hotkey" ? 1 : 0
        anchors.fill: parent
        enabled: triggerMode === "hotkey"
    }
}