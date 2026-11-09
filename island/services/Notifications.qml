// island/services/Notifications.qml - Notifications service with DBus portal check

pragma Singleton
import QtQuick 2.15
import Quickshell.Services.Notifications
import Quickshell.Io

Item {
    id: notificationsService

    // Check if freedesktop Notifications portal is available
    property bool portalAvailable: false

    // Process for checking DBus portal
    Process {
        id: portalCheckProc
        command: ["busctl", "--user", "list", "--acquired"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text && (text.indexOf("org.freedesktop.Notifications") !== -1 ||
                             text.indexOf("org.kde.plasma.Notifications") !== -1)) {
                    notificationsService.portalAvailable = true
                    console.log("Notification portal available")
                } else {
                    notificationsService.portalAvailable = false
                    console.warn("No notification daemon found on DBus. Install mako, dunst, or enable plasma notifications.")
                }
            }
        }
    }

    Component.onCompleted: portalCheckProc.running = true

    // Re-check portal periodically
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: portalCheckProc.running = true
    }

    readonly property var notifications: Notifications.notifications

    function clearAll() {
        Notifications.clearAll()
    }
}