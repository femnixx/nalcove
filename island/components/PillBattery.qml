// island/components/PillBattery.qml - Stub for battery pill (transient live activity)

import QtQuick 2.15
import qs.components 1.0 as Style

Item {
    id: pillBatteryRoot

    property int percentage: 0
    property bool charging: false
    property bool active: false

    width: Style.idleWidth
    height: Style.idleHeight
    opacity: active ? 1 : 0
    enabled: active
}
