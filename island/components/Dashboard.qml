import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../services" as Services
import qs.components 1.0

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

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // --- TOP BAR: Main tabs on left ---
        RowLayout {
            id: tabsRow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            spacing: 8

            Repeater {
                model: [
                    ["home", "home", "Home"],
                    ["music", "music", "Music"],
                    ["clipboard", "clipboard", "Clipboard"],
                    ["alerts", "bell", "Alerts"],
                    ["shelf", "folder", "Shelf"],
                    ["notes", "notebook", "Notes"]
                ]
                delegate: Item {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 36
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: isActive ? "#3b8bff" : "transparent"
                        border.color: isActive ? "#3b8bff" : "transparent"
                        border.width: isActive ? 1 : 0
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Icon {
                                name: iconName
                                size: 14
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                anchors.horizontalCenter: parent.horizontalCenter
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            Text {
                                text: label
                                font.pixelSize: 9
                                font.bold: true
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                anchors.horizontalCenter: parent.horizontalCenter
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

        // --- SECOND ROW: Smaller icons spread across + battery on right ---
        RowLayout {
            id: utilityRow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            spacing: 10

            Repeater {
                model: [
                    ["controls", "sliders", "Controls"],
                    ["bluetooth", "bluetooth", "Bluetooth"],
                    ["calendar", "calendar", "Calendar"],
                    ["search", "search", "Search"],
                    ["wifi", "wifi", "Wi-Fi"],
                    ["system", "activity", "System"],
                    ["settings", "settings", "Settings"]
                ]
                delegate: Item {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 36
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: isActive ? "#3b8bff" : "transparent"
                        border.color: isActive ? "#3b8bff" : "transparent"
                        border.width: isActive ? 1 : 0
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 1
                            Icon {
                                name: iconName
                                size: 14
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                anchors.horizontalCenter: parent.horizontalCenter
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            Text {
                                text: label
                                font.pixelSize: 7
                                font.bold: true
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                anchors.horizontalCenter: parent.horizontalCenter
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

            // Spacer pushes battery to the right
            Item { Layout.fillWidth: true }

            // Battery indicator on the right - percentage first, then icon
            Row {
                spacing: 6

                Text {
                    text: Math.round(Services.Battery.pct * 100) + "%"
                    color: Services.Battery.accent
                    font.pixelSize: 10
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Icon {
                    name: Services.Battery.charging ? "battery-charging" : (Services.Battery.low ? "battery-low" : "battery")
                    size: 14
                    color: "#9a9aa0"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 6 }
            }
        }

        // Divider line below second row
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#2a2a2e"
            Layout.topMargin: 4
        }

        // --- CONTENT AREA: Tab panels ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

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
}
