// island/components/PillMedia.qml - Stub for media pill (compact live activity)

import QtQuick 2.15
import qs.components 1.0 as Style

Item {
    id: pillMediaRoot

    property bool active: false
    property string title: ""
    property string artist: ""
    property string albumArt: ""

    width: Style.idleWidth
    height: Style.idleHeight
    opacity: active ? 1 : 0
    enabled: active
}
