// island/components/Hud.qml - Stub for HUD replacements (volume, brightness)

import QtQuick 2.15
import qs.components 1.0 as Style

Item {
    id: hudRoot

    property string type: "volume"     // "volume" | "brightness"
    property int value: 0
    property bool muted: false
    property bool active: false

    width: Style.idleWidth
    height: Style.idleHeight
    opacity: active ? 1 : 0
    enabled: active
}
