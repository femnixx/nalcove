// island/services/Power.qml - Stub: UPower power service wrapper

import QtQuick 2.15
import Quickshell.Services.UPower

Item {
    id: powerService

    property int percentage: 0
    property bool charging: false
    property bool onBattery: true

    Component.onCompleted: {
        // Stub - replaced in Phase 5
    }
}
