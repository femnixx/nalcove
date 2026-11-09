// island/services/Notifications.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: n => { n.tracked = true }
    }

    function clearAll() {
        for (const n of list.slice()) n.dismiss()
    }
}