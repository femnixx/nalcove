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
    property real ui: 1

    function s(px) { return Math.round(px * ui) }

    // Tab rows switch to icons-only below this width.
    readonly property bool narrow: width < 640

    // Every tab cell in BOTH rows has this width and the rows use the same spacing,
    // so the two rows line up column for column. Tabs pack to the left.
    readonly property real tabW: s(68)
    readonly property real tabGap: s(8)

    // Page loaders only exist while the island is open (or fading out), so a closed
    // island holds almost no memory. Set this to `true` if opening ever feels janky.
    readonly property bool alive: active || opacity > 0

    function fmtTime(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    // Size comes from the parent (IslandWindow gives it a fixed width/height).
    // No anchors.fill here, or it would fight the size set from outside.

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: s(20)
        anchors.rightMargin: s(20)
        anchors.bottomMargin: s(14)
        spacing: s(8)

        // --- TOP BAR: main tabs, fixed-width cells packed to the left ---
        RowLayout {
            id: tabsRow
            Layout.fillWidth: true
            Layout.topMargin: s(8)
            spacing: dashboardRoot.tabGap

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
                    Layout.fillWidth: false
                    Layout.preferredWidth: dashboardRoot.tabW
                    Layout.preferredHeight: s(36)
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId
                    property bool showLabel: !dashboardRoot.narrow

                    Rectangle {
                        anchors.fill: parent
                        radius: s(10)
                        color: isActive ? "#3b8bff" : "transparent"
                        border.color: isActive ? "#3b8bff" : "transparent"
                        border.width: isActive ? 1 : 0
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: s(2)
                            Icon {
                                name: iconName
                                size: s(14)
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                anchors.horizontalCenter: parent.horizontalCenter
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            Text {
                                text: showLabel ? label : ""
                                font.pixelSize: 9 * ui
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

            // Takes the leftover width so the tabs stay packed on the left
            Item { Layout.fillWidth: true }
        }

        // --- SECOND ROW: smaller tabs packed left, battery pinned to the right ---
        RowLayout {
            id: utilityRow
            Layout.fillWidth: true
            Layout.topMargin: s(6)
            Layout.preferredHeight: s(36)
            spacing: dashboardRoot.tabGap

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
                    Layout.fillWidth: false
                    Layout.preferredWidth: dashboardRoot.tabW
                    Layout.preferredHeight: s(36)
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId
                    property bool showLabel: !dashboardRoot.narrow

                    Rectangle {
                        anchors.fill: parent
                        radius: s(10)
                        color: isActive ? "#3b8bff" : "transparent"
                        border.color: isActive ? "#3b8bff" : "transparent"
                        border.width: isActive ? 1 : 0
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: s(1)
                            Icon {
                                name: iconName
                                size: s(14)
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                anchors.horizontalCenter: tabLabel.horizontalCenter
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            Text {
                                id: tabLabel
                                text: showLabel ? label : ""
                                font.pixelSize: 7 * ui
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

            // Spacer pushes the battery to the far right
            Item { Layout.fillWidth: true }

            // Battery indicator on the right: percentage first, then icon
            Row {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                spacing: s(6)

                Text {
                    text: Math.round(Services.Battery.pct * 100) + "%"
                    color: Services.Battery.accent
                    font.pixelSize: 10 * ui
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Icon {
                    name: Services.Battery.charging ? "battery-charging" : (Services.Battery.low ? "battery-low" : "battery")
                    size: s(14)
                    color: "#9a9aa0"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Divider line below second row
        Rectangle {
            Layout.fillWidth: true
            height: s(1)
            color: "#2a2a2e"
            Layout.topMargin: s(4)
        }

        // --- CONTENT AREA: Tab panels (only the active page is loaded) ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader { id: homeLoader; anchors.fill: parent; active: alive && page === "home"; source: "HomeTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: musicLoader;  anchors.fill: parent; active: alive && page === "music";     source: "MusicTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: clipboardLoader; anchors.fill: parent; active: alive && page === "clipboard"; source: "ClipboardTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: alertsLoader;   anchors.fill: parent; active: alive && page === "alerts";    source: "AlertsTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: shelfLoader;    anchors.fill: parent; active: alive && page === "shelf";     source: "ShelfTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: notesLoader;    anchors.fill: parent; active: alive && page === "notes";     source: "NotesTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: calendarLoader; anchors.fill: parent; active: alive && page === "calendar";  source: "CalendarTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: controlsLoader; anchors.fill: parent; active: alive && page === "controls";  source: "ControlsTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: bluetoothLoader;anchors.fill: parent; active: alive && page === "bluetooth"; source: "BluetoothTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: systemLoader;   anchors.fill: parent; active: alive && page === "system";    source: "SystemTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: wifiLoader;     anchors.fill: parent; active: alive && page === "wifi";      source: "WifiTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: searchLoader;   anchors.fill: parent; active: alive && page === "search";    source: "SearchTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
            Loader { id: settingsLoader; anchors.fill: parent; active: alive && page === "settings";  source: "SettingsTab.qml";
                     onLoaded: if (item) item.ui = dashboardRoot.ui }
        }
    }
}
