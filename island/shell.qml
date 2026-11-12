// island/shell.qml - Quickshell Dynamic Island (niri / any wlr-layer-shell compositor)
// Run with: qs -p ./island
// Toggle:   qs -p ./island ipc call island toggle
// One IslandWindow per screen; each window computes its own `ui` from its screen.

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import "services"
import "components"
import qs.components 1.0

ShellRoot {
    IslandWindow {
    }
}
