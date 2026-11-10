// island/components/Hud.qml - Stub for HUD replacements (volume, brightness)
import qs.components 1.0

import QtQuick 2.15


Item {
    id: hudRoot

    property string type: "volume"     // "volume" | "brightness"
    property int value: 0
    property bool muted: false
    property bool active: false

    width: Theme.idleWidth
    height: Theme.idleHeight
    opacity: active ? 1 : 0
    enabled: active
}
