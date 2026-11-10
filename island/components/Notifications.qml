// island/components/Notifications.qml - Notifications service wrapper (singleton)

pragma Singleton
import QtQuick 2.15
import "../services" as Services

Item {
    id: notificationsService

    readonly property var notifications: Services.Notifications.list

    function clearAll() {
        Services.Notifications.clearAll()
    }

    function dismiss(id) {
        Services.Notifications.dismiss(id)
    }
}