pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // NotificationServer properly registers as a D-Bus notification daemon
    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        imageSupported: true

        // Track all notifications so they persist in the model
        onNotification: n => {
            n.tracked = true
            root._updateList()
            root.received(n)
        }
    }

    // Public API for UI
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length

    signal received(var n)

    function dismiss(id) {
        var n = findById(id)
        if (n) n.dismiss()
    }

    function clearAll() {
        server.clearAll()
        root._updateList()
    }

    function findById(id) {
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) return list[i]
        }
        return null
    }

    // DND support
    property bool dnd: false

    function setDnd(enabled) {
        dnd = enabled
    }

    function _updateList() {
        // Force property update
        list = server.trackedNotifications.values
    }
}