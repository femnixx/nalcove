pragma Singleton
import QtQuick 2.15

Item {
    id: statsService

    property real cpuPercent: 0
    property real ramPercent: 0
    property real diskPercent: 0

    Component.onCompleted: {
        // Stub - replaced in Phase 6
    }
}