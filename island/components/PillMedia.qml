// island/components/PillMedia.qml - Stub for media pill (compact live activity)
import qs.components as Theme

import QtQuick 2.15


Item {
    id: pillMediaRoot

    property bool active: false
    property string title: ""
    property string artist: ""
    property string albumArt: ""

    width: Theme.idleWidth
    height: Theme.idleHeight
    opacity: active ? 1 : 0
    enabled: active
}
