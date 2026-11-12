import QtQuick
import "../services" as Services

Item {
    id: wifi
    property real ui: 1

    // UI state lives HERE, keyed by ssid, not in delegates, so it survives model updates
    property string expandedSsid: ""
    property string draft: ""            // password being typed
    property bool showingSaved: false

    function s(px) { return Math.round(px * ui) }

    Component.onCompleted: Services.Network.users = Services.Network.users + 1
    Component.onDestruction: Services.Network.users = Services.Network.users - 1

    Connections {
        target: Services.Network
        function onPasswordRead(uuid, pw) { wifi.draft = pw; wifi.showingSaved = true }
    }

    function toggle(ssid) {
        expandedSsid = (expandedSsid === ssid) ? "" : ssid
        draft = ""; showingSaved = false
        Services.Network.lastError = ""
    }

    // ---- header ----
    Row {
        id: header
        width: parent.width; height: s(32); spacing: s(10)
        Text { text: "Wi-Fi"; color: "#ffffff"; font.pixelSize: 16 * ui; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
        Item { width: parent.width - s(260); height: s(1) }

        Rectangle {   // on/off switch
            width: s(40); height: s(22); radius: s(11); anchors.verticalCenter: parent.verticalCenter
            color: Services.Network.wifiEnabled ? "#3b8bff" : "#3a3a3e"
            Rectangle { width: s(18); height: s(18); radius: s(9); y: s(2); color: "#ffffff"
                        x: Services.Network.wifiEnabled ? s(20) : s(2)
                        Behavior on x { NumberAnimation { duration: 120 } } }
            MouseArea { anchors.fill: parent; onClicked: Services.Network.setWifiEnabled(!Services.Network.wifiEnabled) }
        }
        Pill { ui: wifi.ui; text: Services.Network.scanning ? "Scanning…" : "Rescan"; enabled: Services.Network.wifiEnabled && !Services.Network.scanning
               anchors.verticalCenter: parent.verticalCenter; onClicked: Services.Network.rescan() }
        Pill { ui: wifi.ui; text: "GNOME settings"; anchors.verticalCenter: parent.verticalCenter; onClicked: Services.Network.openGnomeSettings() }
    }

    Text {
        id: status
        anchors.top: header.bottom; anchors.topMargin: s(6)
        width: parent.width; elide: Text.ElideRight; font.pixelSize: 11 * ui
        color: Services.Network.lastError !== "" ? "#ff453a" : "#9a9aa0"
        text: Services.Network.lastError !== "" ? Services.Network.lastError
            : !Services.Network.wifiEnabled ? "Wi-Fi is off"
            : Services.Network.activeSsid !== "" ? "Connected to " + Services.Network.activeSsid
                + (Services.Network.activeIp !== "" ? "  ·  " + Services.Network.activeIp : "")
            : "Not connected"
    }

    // ---- network list ----
    ListView {
        id: list
        anchors.top: status.bottom; anchors.topMargin: s(6)
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        clip: true; spacing: s(4); reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        visible: Services.Network.wifiEnabled
        model: Services.Network.networkModel

        delegate: Item {
            id: row
            required property var model
            readonly property bool expanded: wifi.expandedSsid === model.ssid
            width: ListView.view.width
            height: head.height + (expanded ? detail.implicitHeight + s(10) : 0)
            clip: true
            Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            Rectangle { anchors.fill: parent; radius: s(10); color: "#1a1a1a" }

            // collapsed header row
            Item {
                id: head
                width: parent.width; height: s(40)
                Icon { x: s(12); anchors.verticalCenter: parent.verticalCenter; name: "wifi"; size: s(16)
                       opacity: 0.35 + 0.65 * (model.signal / 100) }
                Text { x: s(38); anchors.verticalCenter: parent.verticalCenter; width: parent.width - s(140)
                       text: model.ssid; color: model.active ? "#3b8bff" : "#ffffff"; font.pixelSize: 12 * ui; elide: Text.ElideRight }
                Row {
                    anchors.right: parent.right; anchors.rightMargin: s(12); anchors.verticalCenter: parent.verticalCenter; spacing: s(8)
                    Text { visible: Services.Network.busySsid === model.ssid; text: "Connecting…"; color: "#9a9aa0"; font.pixelSize: 11 * ui }
                    Text { visible: model.saved && !model.active; text: "Saved"; color: "#9a9aa0"; font.pixelSize: 11 * ui }
                    Icon  { visible: model.secured; name: "lock"; size: s(12); color: "#9a9aa0" }
                    Text  { text: model.signal + "%"; color: "#9a9aa0"; font.pixelSize: 11 * ui }
                }
                MouseArea { anchors.fill: parent; onClicked: wifi.toggle(model.ssid) }
            }

            // inline detail panel
            Column {
                id: detail
                anchors.top: head.bottom
                x: s(12); width: parent.width - s(24); spacing: s(8)
                visible: row.expanded

                // password: new secured network
                Column {
                    width: parent.width; spacing: s(6)
                    visible: model.secured && !model.saved
                    Text { text: "Password"; color: "#9a9aa0"; font.pixelSize: 11 * ui }
                    PasswordField {
                        width: parent.width
                        text: wifi.draft
                        onEdited: v => wifi.draft = v
                        onAccepted: Services.Network.connectTo(model.ssid, wifi.draft)
                    }
                }

                // password: saved network (view and edit)
                Column {
                    width: parent.width; spacing: s(6)
                    visible: model.secured && model.saved
                    Text { text: "Saved password"; color: "#9a9aa0"; font.pixelSize: 11 * ui }
                    PasswordField {
                        width: parent.width
                        placeholder: wifi.showingSaved ? "" : "Hidden. Click “Show saved” to reveal or edit"
                        revealed: wifi.showingSaved
                        text: wifi.draft
                        onEdited: v => wifi.draft = v
                        onAccepted: if (wifi.draft !== "") Services.Network.setPassword(model.uuid, wifi.draft)
                    }
                    Row {
                        spacing: s(6)
                        Pill { ui: wifi.ui; text: "Show saved"; visible: !wifi.showingSaved; onClicked: Services.Network.readPassword(model.uuid) }
                        Pill { ui: wifi.ui; text: "Save password"; accent: true; visible: wifi.showingSaved && wifi.draft !== ""
                               onClicked: Services.Network.setPassword(model.uuid, wifi.draft) }
                    }
                }

                // actions
                Flow {
                    width: parent.width; spacing: s(6)
                    Pill { ui: wifi.ui; text: "Connect"; accent: true; visible: !model.active
                           busy: Services.Network.busySsid === model.ssid
                           enabled: !model.secured || model.saved || wifi.draft.length >= 8
                           onClicked: Services.Network.connectTo(model.ssid, wifi.draft) }
                    Pill { ui: wifi.ui; text: "Disconnect"; visible: model.active; onClicked: Services.Network.disconnect(model.uuid) }
                    Pill { ui: wifi.ui; text: "Network settings"; visible: model.saved; onClicked: Services.Network.openNetworkEditor(model.uuid) }
                    Pill { ui: wifi.ui; text: "Forget"; danger: true; visible: model.saved
                           onClicked: { Services.Network.forget(model.uuid); wifi.toggle(model.ssid) } }
                }
                Item { width: s(1); height: s(2) }
            }
        }
    }
}
