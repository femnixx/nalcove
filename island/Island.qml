// island/Island.qml - Window + state machine
// States: closed | hover | hotkey

import QtQuick 2.15
import Quickshell.Window
import Quickshell.WlrLayershell
import Quickshell.Ipc
import Island 1.0 as Theme

PanelWindow {
    id: islandWindow

    // Window rules
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "island"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Fixed size: expanded + overshoot margin, never resize during animation
    width: Theme.windowWidth
    height: Theme.windowHeight

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
        if (triggerMode === "hotkey") Theme.expandedWidth
        else if (triggerMode === "hover") Theme.hoverWidth
        else Theme.idleWidth
    }
    property int currentHeight: {
        if (triggerMode === "hotkey") Theme.expandedHeight
        else if (triggerMode === "hover") Theme.hoverHeight
        else Theme.idleHeight
    }
    property int currentBottomRadius: {
        if (triggerMode === "hotkey") Theme.expandedBottomRadius
        else if (triggerMode === "hover") Theme.hoverBottomRadius
        else Theme.idleBottomRadius
    }

    // Spring animations on size properties
    Behavior on currentWidth {
        SpringAnimation {
            spring: Theme.springWidth
            damping: Theme.dampingWidth
            epsilon: Theme.epsilonWidth
        }
    }
    Behavior on currentHeight {
        SpringAnimation {
            spring: Theme.springHeight
            damping: Theme.dampingHeight
            epsilon: Theme.epsilonHeight
        }
    }
    Behavior on currentBottomRadius {
        SpringAnimation {
            spring: Theme.springRadius
            damping: Theme.dampingRadius
            epsilon: Theme.epsilonRadius
        }
    }

    // Notch shape centered at top of window
    IslandShape {
        id: islandShape
        width: currentWidth
        height: currentHeight
        bottomRadius: currentBottomRadius
        flare: Theme.flareRadius

        // Center at top of window, offset by overshoot margin
        x: (parent.width - width) / 2
        y: Theme.overshootMargin

        // Opaque fill (95% opacity)
        fillColor: "#f2101012"
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

    // DropArea for shelf - tracks animated shape
    DropArea {
        anchors.fill: islandShape
        onEntered: {
            if (triggerMode !== "hotkey") triggerMode = "hotkey"
            openPage("shelf")
        }
    }

    Timer {
        id: hoverDebounceTimer
        interval: Theme.hoverDebounceMs
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

    // Page navigation signal from DropArea
    signal openPage(string page)

    // Stub: expanded content placeholder
    Item {
        id: expandedContent
        visible: triggerMode === "hotkey"
        opacity: triggerMode === "hotkey" ? 1 : 0
        anchors.fill: parent
        enabled: triggerMode === "hotkey"
    }
}