import QtQuick
import "../services" as Services

Item {
    id: dashboardRoot
    property string page: "home"
    property bool pinned: false
    property bool active: false
    anchors.fill: parent

    function fmtTime(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    // --- TOP BAR: Navigation Tabs ---
    Rectangle {
        id: tabBar
        x: 20; y: 12
        width: 740; height: 44
        color: "transparent"

        Row {
            anchors.fill: parent
            spacing: 8

            Repeater {
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
                    width: 84; height: 44
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: isActive ? "#3b8bff" : "transparent"
                        border.color: isActive ? "#3b8bff" : "transparent"
                        border.width: isActive ? 1 : 0
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Icon {
                                name: iconName
                                size: 20
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            Text {
                                text: label
                                font.pixelSize: 9
                                font.bold: true
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: dashboardRoot.page = pageId
                        }
                    }
                }
            }
        }
    }

    // --- UTILITY ROW: Lower icons (aligned with tabs) ---
    Row {
        id: utilityRow
        x: 20; y: 72
        width: 740
        height: 24
        spacing: 8

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

                Icon {
                    name: iconName
                    size: 16
                    color: "#9a9aa0"
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: dashboardRoot.page = pageId
                }
            }
        }
    }

    // Separator line below utility row
    Rectangle {
        x: 20; y: 98
        width: 740; height: 1
        color: "#2a2a2e"
    }

    // --- CONTENT AREA: Tab panels ---
    Item {
        x: 20; y: 106
        width: 740
        height: parent.height - 118

        // Lazy-loaded tabs using Loader
        Loader { anchors.fill: parent; active: page === "home";      source: "HomeTab.qml" }
        Loader { anchors.fill: parent; active: page === "music";     source: "MusicTab.qml" }
        Loader { anchors.fill: parent; active: page === "clipboard"; source: "ClipboardTab.qml" }
        Loader { anchors.fill: parent; active: page === "alerts";    source: "AlertsTab.qml" }
        Loader { anchors.fill: parent; active: page === "shelf";     source: "ShelfTab.qml" }
        Loader { anchors.fill: parent; active: page === "notes";     source: "NotesTab.qml" }
        Loader { anchors.fill: parent; active: page === "calendar";  source: "CalendarTab.qml" }
        Loader { anchors.fill: parent; active: page === "controls";  source: "ControlsTab.qml" }
        Loader { anchors.fill: parent; active: page === "bluetooth"; source: "BluetoothTab.qml" }
        Loader { anchors.fill: parent; active: page === "system";    source: "SystemTab.qml" }
        Loader { anchors.fill: parent; active: page === "wifi";      source: "WifiTab.qml" }
        Loader { anchors.fill: parent; active: page === "search";    source: "SearchTab.qml" }
        Loader { anchors.fill: parent; active: page === "settings";  source: "SettingsTab.qml" }
    }
}