// island/Island.qml - Window + state machine
// States: closed | hover | notify | hotkey

import QtQuick 2.15
import Quickshell.Window
import Quickshell.Wayland
import Quickshell.Ipc
import Quickshell.Io
import Quickshell.Widgets

PanelWindow {
    id: islandWindow

    // Window rules
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "island"
    WlrLayershell.keyboardFocus: triggerMode === "hotkey"
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    // Fixed size: expanded + overshoot margin, never resize during animation
    width: Theme.windowWidth
    height: Theme.windowHeight

    // Anchor flush to top edge, centered horizontally
    anchors.top: true
    anchors.left: parent.left + (parent.width - width) / 2
    anchors.right: parent.right - (parent.width - width) / 2

    // State machine
    property string triggerMode: "closed"   // "closed" | "hover" | "notify" | "hotkey"

    // Notification peek state
    property var peekNotification: null
    property bool peekHovered: false

    // Hitbox region tracks the island's current animated rect
    property item hitbox: islandShape

    // Derived size from state
    property int currentWidth: triggerMode === "hotkey" ? Theme.expandedWidth
        : (triggerMode === "notify" ? Theme.notifyWidth
        : (triggerMode === "hover" ? Theme.hoverWidth : Theme.idleWidth))
    property int currentHeight: triggerMode === "hotkey" ? Theme.expandedHeight
        : (triggerMode === "notify" ? Theme.notifyHeight
        : (triggerMode === "hover" ? Theme.hoverHeight : Theme.idleHeight))
    property int currentBottomRadius: triggerMode === "hotkey" ? Theme.expandedBottomRadius
        : (triggerMode === "hover" ? Theme.hoverBottomRadius : Theme.rSm)

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
        fillColor: Theme.bg
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
        hoverEnabled: triggerMode === "closed" || triggerMode === "hover"

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
        onDropped: drop => { if (drop.hasUrls) Shelf.addUrls(drop.urls) }
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

    // Notification peek timeout timer
    Timer {
        id: notifyTimeout
        interval: 5000
        repeat: false
        onTriggered: {
            if (triggerMode === "notify" && !peekHovered) {
                triggerMode = "closed"
                peekNotification = null
            }
        }
    }

    // Listen for notifications
    Connections {
        target: Services.Notifications
        function onReceived(n) {
            if (triggerMode === "hotkey") return
            if (Services.Notifications.dnd) return

            peekNotification = n
            triggerMode = "notify"
            notifyTimeout.interval = n.expireTimeout > 0 ? n.expireTimeout : 5000
            notifyTimeout.restart()
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

    // ===== CONTENT STACK =====
    Item {
        anchors.fill: parent

        // ===== Compact pill (closed): artwork + bars =====
        Item {
            anchors.fill: parent
            opacity: (triggerMode === "closed" && Media.isPlaying) ? 1 : 0
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
                                running: parent.opacity > 0.5 && Media.isPlaying
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
            opacity: triggerMode === "hover" ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: triggerMode === "hover" ? 80 : 0 }
                    NumberAnimation { duration: 150 }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: triggerMode = "hotkey"
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
            opacity: triggerMode === "notify" ? 1 : 0
            visible: opacity > 0.01 && peekNotification !== null
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: 0 }
                    NumberAnimation { duration: 150 }
                }
            }

            property var n: peekNotification

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: peekHovered = true
                onExited: peekHovered = false
                onClicked: triggerMode = "hotkey"
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
                                    peekNotification.dismiss()
                                    triggerMode = "closed"
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
            active: triggerMode === "hotkey"
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