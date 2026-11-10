// island/services/Notifications.qml - Notifications service wrapper (singleton)

pragma Singleton
import QtQuick 2.15
import Quickshell.Services.Notifications

Item {
    id: notificationsService

    readonly property var notifications: Notifications.notifications

    function clearAll() {
        Notifications.clearAll()
    }
}