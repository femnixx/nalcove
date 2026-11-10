import QtQuick
import qs.components as Theme
import QtQuick.Controls
import "../services" as Services


Item {
    id: dashboardRoot
    property string page: "home"
    property bool pinned: false
    property bool active: false
    anchors.fill: parent

    // Active tab indicator animation
    property real indicatorX: 0
    property real indicatorWidth: 84

    // --- TOP BAR: Navigation Tabs ---
    Rectangle {
        id: tabBar
        x: Theme.s4
        y: Theme.s3
        width: parent.width - Theme.s4 * 2
        height: Theme.rowH
        color: "transparent"

        // Sliding indicator
        Rectangle {
            id: tabIndicator
            y: 0
            height: parent.height
            radius: Theme.pillRadius
            color: Theme.accent
            x: dashboardRoot.indicatorX
            width: dashboardRoot.indicatorWidth
            Behavior on x { SpringAnimation { spring: 3; damping: 0.4 } }
            Behavior on width { SpringAnimation { spring: 3; damping: 0.4 } }
        }

        Row {
            anchors.fill: parent
            spacing: Theme.s2

            Repeater {
                id: tabRepeater
                model: [
                    ["home", "home", "Home"],
                    ["music", "music", "Music"],
                    ["clipboard", "clipboard", "Clipboard"],
                    ["alerts", "bell", "Alerts"],
                    ["shelf", "folder", "Shelf"],
                    ["notes", "notebook", "Notes"],
                    ["controls", "layers", "Controls"],
                    ["bluetooth", "bluetooth", "Bluetooth"]
                ]
                delegate: Item {
                    id: tabItem
                    width: 84
                    height: Theme.rowH
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.pillRadius
                        color: "transparent"
                        z: -1

                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Icon {
                                name: iconName
                                size: Theme.iconMd
                                color: isActive ? "#ffffff" : Theme.dim
                                Behavior on color { ColorAnimation { duration: Theme.dFast } }
                            }
                            Text {
                                text: label
                                font.pixelSize: Theme.tCaption
                                font.bold: true
                                font.family: Theme.fontFamily
                                color: isActive ? "#ffffff" : Theme.dim
                                Behavior on color { ColorAnimation { duration: Theme.dFast } }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if (!isActive) {
                                dashboardRoot.indicatorX = tabItem.x
                                dashboardRoot.indicatorWidth = tabItem.width
                            }
                        }
                        onExited: {
                            if (!isActive) {
                                var activeItem = tabRepeater.itemAt(tabRepeater.model.indexOf(dashboardRoot.page))
                                if (activeItem) {
                                    dashboardRoot.indicatorX = activeItem.x
                                    dashboardRoot.indicatorWidth = activeItem.width
                                }
                            }
                        }
                        onClicked: {
                            dashboardRoot.page = pageId
                            dashboardRoot.indicatorX = tabItem.x
                            dashboardRoot.indicatorWidth = tabItem.width
                        }
                    }
                }
            }
        }
    }

    // --- UTILITY ROW: Lower icons (aligned with tabs) ---
    Row {
        id: utilityRow
        x: Theme.s4
        y: tabBar.y + tabBar.height + Theme.s2
        width: parent.width - Theme.s4 * 2
        height: 24
        spacing: Theme.s2

        Repeater {
            model: [
                ["calendar", "calendar", "Calendar"],
                ["search", "search", "Search"],
                ["wifi", "wifi", "Wi-Fi"],
                ["system", "activity", "System"],
                ["settings", "settings", "Settings"]
            ]
            delegate: Item {
                width: 84; height: 24
                property string pageId: modelData[0]
                property string iconName: modelData[1]
                property string label: modelData[2]

                ToolTip {
                    text: label
                    delay: 500
                    visible: parent.hovered
                }

                Icon {
                    name: iconName
                    size: Theme.iconMd
                    color: Theme.dim
                    anchors.centerIn: parent
                    Behavior on color { ColorAnimation { duration: Theme.dFast } }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.Icon.color = Theme.fg
                    onExited: parent.Icon.color = Theme.dim
                    onClicked: dashboardRoot.page = pageId
                }
            }
        }
    }

    // Separator line below utility row
    Rectangle {
        x: Theme.s4
        y: utilityRow.y + utilityRow.height + Theme.s2
        width: parent.width - Theme.s4 * 2
        height: 1
        color: Theme.cardBorder
    }

    // --- CONTENT AREA: Tab panels ---
    Item {
        id: contentArea
        x: Theme.s4
        y: utilityRow.y + utilityRow.height + Theme.s2 + 2
        width: parent.width - Theme.s4 * 2
        height: parent.height - y

        // Lazy-loaded tabs using Loader with cross-fade
        Loader { id: homeLoader;      anchors.fill: parent; active: page === "home";      source: "HomeTab.qml" }
        Loader { id: musicLoader;     anchors.fill: parent; active: page === "music";     source: "MusicTab.qml" }
        Loader { id: clipboardLoader; anchors.fill: parent; active: page === "clipboard"; source: "ClipboardTab.qml" }
        Loader { id: alertsLoader;    anchors.fill: parent; active: page === "alerts";    source: "AlertsTab.qml" }
        Loader { id: shelfLoader;     anchors.fill: parent; active: page === "shelf";     source: "ShelfTab.qml" }
        Loader { id: notesLoader;     anchors.fill: parent; active: page === "notes";     source: "NotesTab.qml" }
        Loader { id: calendarLoader;  anchors.fill: parent; active: page === "calendar";  source: "CalendarTab.qml" }
        Loader { id: controlsLoader;  anchors.fill: parent; active: page === "controls";  source: "ControlsTab.qml" }
        Loader { id: bluetoothLoader; anchors.fill: parent; active: page === "bluetooth"; source: "BluetoothTab.qml" }
        Loader { id: systemLoader;    anchors.fill: parent; active: page === "system";    source: "SystemTab.qml" }
        Loader { id: wifiLoader;      anchors.fill: parent; active: page === "wifi";      source: "WifiTab.qml" }
        Loader { id: searchLoader;    anchors.fill: parent; active: page === "search";    source: "SearchTab.qml" }
        Loader { id: settingsLoader;  anchors.fill: parent; active: page === "settings";  source: "SettingsTab.qml" }
    }

    // Initialize indicator position
    Component.onCompleted: {
        var activeItem = tabRepeater.itemAt(tabRepeater.model.indexOf(page))
        if (activeItem) {
            indicatorX = activeItem.x
            indicatorWidth = activeItem.width
        }
    }
}// RECOMPILE Tue Nov 10 11:25:54 AM WIB 2026
