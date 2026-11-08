pragma Singleton
import Quickshell
import QtQuick

// Shared clock. Only ticks while `active` (island open), so zero cost when closed.
Singleton {
    id: root
    property bool active: false
    property date now: new Date()

    Timer {
        interval: 15000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }
}
