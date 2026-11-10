import QtQuick
import qs.components 1.0
import QtQuick.Layouts
import "../services" as Services


Item {
    id: wifi

    // UI state lives HERE, keyed by ssid, not in delegates, so it survives model updates
    property string expandedSsid: ""
    property string draft: ""
    property bool showingSaved: false

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

    Column {
        anchors.fill: parent
        spacing: Theme.s2

        // ---- header ----
        RowLayout {
            Layout.fillWidth: true
            height: Theme.rowH
            spacing: Theme.s2

            Text {
                text: "Wi-Fi"
                font.pixelSize: Theme.tTitle
                font.bold: true
                font.family: Theme.fontFamily
                color: Theme.fg
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Switch {
                checked: Services.Network.wifiEnabled
                onToggled: Services.Network.setWifiEnabled(checked)
                Layout.alignment: Qt.AlignVCenter
            }

            Pill {
                text: Services.Network.scanning ? "Scanning…" : "Rescan"
                enabled: Services.Network.wifiEnabled && !Services.Network.scanning
                Layout.alignment: Qt.AlignVCenter
                onClicked: Services.Network.rescan()
            }

            Pill {
                text: root.width > 520 ? "GNOME settings" : ""
                icon: "settings"
                iconOnly: root.width <= 520
                tooltip: "GNOME settings"
                Layout.alignment: Qt.AlignVCenter
                onClicked: Services.Network.openGnomeSettings()
            }
        }

        Text {
            id: status
            width: parent.width
            elide: Text.ElideRight
            font.pixelSize: Theme.tSmall
            font.family: Theme.fontFamily
            color: Services.Network.lastError !== "" ? Theme.danger : Theme.dim
            text: Services.Network.lastError !== "" ? Services.Network.lastError
                : !Services.Network.wifiEnabled ? "Wi-Fi is off"
                : Services.Network.activeSsid !== "" ? "Connected to " + Services.Network.activeSsid
                    + (Services.Network.activeIp !== "" ? "  ·  " + Services.Network.activeIp : "")
                : "Not connected"
        }

        // ---- network list ----
        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 0
            clip: true
            spacing: 4
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            visible: Services.Network.wifiEnabled
            model: Services.Network.networkModel

            delegate: Item {
                id: row
                required property var model
                readonly property bool expanded: wifi.expandedSsid === model.ssid
                width: ListView.view.width
                height: head.height + (expanded ? detail.implicitHeight + 10 : 0)
                clip: true
                Behavior on height { NumberAnimation { duration: 140; easing.type: Theme.easingOutCubic } }

                Card {
                    anchors.fill: parent
                    hoverEnabled: false
                }

                // collapsed header row
                Item {
                    id: head
                    width: parent.width; height: 44
                    Icon { x: Theme.s4; anchors.verticalCenter: parent.verticalCenter; name: "wifi"; size: Theme.iconMd
                           opacity: 0.35 + 0.65 * (model.signal / 100) }
                    Text { x: Theme.s4 * 3; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 160
                           text: model.ssid; color: model.active ? Theme.accent : Theme.fg; font.pixelSize: Theme.tBody; font.family: Theme.fontFamily; elide: Text.ElideRight }
                    Row {
                        anchors.right: parent.right; anchors.rightMargin: Theme.s4; anchors.verticalCenter: parent.verticalCenter; spacing: Theme.s2
                        Text { visible: Services.Network.busySsid === model.ssid; text: "Connecting…"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                        Text { visible: model.saved && !model.active; text: "Saved"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                        Icon  { visible: model.secured; name: "lock"; size: Theme.iconSm; color: Theme.dim }
                        Text  { text: model.signal + "%"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                    }
                    MouseArea { anchors.fill: parent; onClicked: wifi.toggle(model.ssid) }
                }

                // inline detail panel
                Column {
                    id: detail
                    anchors.top: head.bottom
                    x: Theme.s4; width: parent.width - Theme.s4 * 2; spacing: Theme.s2
                    visible: row.expanded

                    // password: new secured network
                    Column {
                        width: parent.width; spacing: Theme.s2
                        visible: model.secured && !model.saved
                        Text { text: "Password"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                        PasswordField {
                            width: parent.width
                            text: wifi.draft
                            onEdited: v => wifi.draft = v
                            onAccepted: Services.Network.connectTo(model.ssid, wifi.draft)
                        }
                    }

                    // password: saved network (view and edit)
                    Column {
                        width: parent.width; spacing: Theme.s2
                        visible: model.secured && model.saved
                        Text { text: "Saved password"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                        PasswordField {
                            width: parent.width
                            placeholder: wifi.showingSaved ? "" : "Hidden. Click \"Show saved\" to reveal or edit"
                            revealed: wifi.showingSaved
                            text: wifi.draft
                            onEdited: v => wifi.draft = v
                            onAccepted: if (wifi.draft !== "") Services.Network.setPassword(model.uuid, wifi.draft)
                        }
                        Row {
                            spacing: Theme.s2
                            Pill { text: "Show saved"; visible: !wifi.showingSaved; onClicked: Services.Network.readPassword(model.uuid) }
                            Pill { text: "Save password"; accent: true; visible: wifi.showingSaved && wifi.draft !== ""
                                   onClicked: Services.Network.setPassword(model.uuid, wifi.draft) }
                        }
                    }

                    // actions
                    Flow {
                        width: parent.width; spacing: Theme.s2
                        Pill { text: "Connect"; accent: true; visible: !model.active
                               busy: Services.Network.busySsid === model.ssid
                               enabled: !model.secured || model.saved || wifi.draft.length >= 8
                               onClicked: Services.Network.connectTo(model.ssid, wifi.draft) }
                        Pill { text: "Disconnect"; visible: model.active; onClicked: Services.Network.disconnect(model.uuid) }
                        Pill { text: "Network settings"; visible: model.saved; onClicked: Services.Network.openNetworkEditor(model.uuid) }
                        Pill { text: "Forget"; danger: true; visible: model.saved
                               onClicked: { Services.Network.forget(model.uuid); wifi.toggle(model.ssid) } }
                    }
                    Item { width: 1; height: Theme.s1 }
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !Services.Network.wifiEnabled || (Services.Network.wifiEnabled && Services.Network.networkModel.count === 0)
            icon: "wifi-off"
            text: !Services.Network.wifiEnabled ? "Wi-Fi is off" : "No networks found"
        }
    }
}