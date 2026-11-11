// island/shell.qml - Quickshell Dynamic Island with DynamicNotch integration
// Run with: qs -p ./island
// Toggle:   qs ipc call island toggle
//@ pragma IconTheme "Papirus-Dark"

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import "services" as Services
import "components"
import qs.components 1.0

ShellRoot {
    PanelWindow {
        id: islandWindow

        anchors { top: true; left: true; right: true }
        implicitHeight: notch.expandedH + 40
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "island"
        WlrLayershell.keyboardFocus: triggerMode === "hotkey"
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // State machine: "closed" | "hover" | "hotkey"
        property string triggerMode: "closed"

        // Close the island as soon as the user clicks outside it (unless pinned).
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            z: -1
            onClicked: {
                if (islandWindow.triggerMode === "hotkey" && !notch.expandedContent.pinned)
                    islandWindow.triggerMode = "closed"
            }
        }

        function toggleHotkey() {
            // While pinned the island stays locked open: toggle unpins first, then closes.
            if (notch.expandedContent.pinned) {
                notch.expandedContent.pinned = false
                islandWindow.triggerMode = "closed"
                return
            }
            triggerMode = (triggerMode === "hotkey") ? "closed" : "hotkey"
        }

        Component.onCompleted: updateKeyboardFocus()
        function updateKeyboardFocus() {
            WlrLayershell.keyboardFocus = (triggerMode === "hotkey")
                ? WlrKeyboardFocus.OnDemand
                : WlrKeyboardFocus.None
        }
        onTriggerModeChanged: {
            updateKeyboardFocus()
            // Map shell state to notch mode:
            //   hotkey   -> expanded (full dashboard)
            //   hover    -> compact  (live activity strip)
            //   closed   -> collapsed (small pill)
            if (triggerMode === "hotkey") {
                notch.mode = "expanded"
                notch.hoverExpands = false
            } else if (triggerMode === "hover") {
                notch.mode = "compact"
                notch.hoverExpands = true
            } else {
                notch.mode = "collapsed"
                notch.hoverExpands = true
            }
        }

        Keys.enabled: triggerMode === "hotkey"
        Keys.onPressed: {
            if (event.key === Qt.Key.Key_Escape)
                islandWindow.triggerMode = "closed"
        }

        // IPC handler for all other compositors: qs ipc call island toggle
        IpcHandler {
            id: islandIpc
            target: "island"
            function toggle() {
                islandWindow.toggleHotkey()
            }
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

        // ---- DynamicNotch: three-state dynamic island container ----
        DynamicNotch {
            id: notch
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            // ---- Collapsed: small pill with media art + activity bars ----
            collapsedContent: Component {
                Item {
                    width: notch.collapsedW; height: notch.collapsedH

                    ClippingRectangle {
                        x: 14; y: 6
                        width: 22; height: 22
                        radius: 6
                        color: "#222222"
                        Image {
                            anchors.fill: parent
                            source: Services.Media.artUrl
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
                                width: 3; height: 16
                                Rectangle {
                                    width: 3; radius: 1.5
                                    color: Style.fg
                                    anchors.centerIn: parent
                                    height: 4 + index * 2
                                    SequentialAnimation on height {
                                        loops: Animation.Infinite
                                        running: notch.mode === "compact" && Media.isPlaying
                                        NumberAnimation { to: 16; duration: 280 + index * 70; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 4; duration: 320 + index * 50; easing.type: Easing.InOutSine }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ---- Compact: media info strip (peek state) ----
            compactContent: Component {
                Item {
                    width: notch.compactW; height: notch.compactH

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
                            source: Services.Media.artUrl
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
                            text: Services.Media.hasPlayer ? Services.Media.title : "Nothing playing"
                            color: Style.fg
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: Services.Media.artist
                            color: Style.dim
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        x: parent.width - 52; y: 22
                        width: 36; height: 36
                        visible: Services.Media.hasPlayer
                        Glyph {
                            anchors.centerIn: parent
                            width: 16; height: 16
                            kind: Services.Media.isPlaying ? "pause" : "play"
                            color: Style.fg
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Services.Media.playPause()
                        }
                    }
                }
            }

            // ---- Expanded: full dashboard with tabbed content ----
            expandedContent: Component {
                Dashboard {
                    id: dashboardRoot
                    anchors.fill: parent
                }
            }
        }
    }
}
