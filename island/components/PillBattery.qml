// island/components/PillBattery.qml - Stub for battery pill (transient live activity)
import qs.components 1.0

import QtQuick 2.15


Item {
    id: pillBatteryRoot

    property int percentage: 0
    property bool charging: false
    property bool active: false

    width: Theme.idleWidth
    height: Theme.idleHeight
    opacity: active ? 1 : 0
    enabled: active
}
