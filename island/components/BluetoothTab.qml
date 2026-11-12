import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: bt
    property real ui: 1
    anchors.fill: parent
    readonly property var adapter: Bluetooth.defaultAdapter

    function s(px) { return Math.round(px * ui) }

    property string selectedAddr: ""
    property string selectedName: ""

    readonly property var devices: {
        if (!adapter) return []
        var list = adapter.devices.values.slice()
        list.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired)
                            || (a.name || "").localeCompare(b.name || ""))
        return list
    }

    function select(addr, name) {
        selectedAddr = addr
        selectedName = name
    }

    function unblockRfkill() {
        Quickshell.execDetached(["rfkill", "unblock", "bluetooth"])
    }

    Component.onDestruction: if (adapter) adapter.discovering = false

    // ---- header: device name + settings + refresh ----
    Item {
        id: header
        width: parent.width; height: s(56)

        Column {
            x: 0; anchors.verticalCenter: parent.verticalCenter; spacing: s(2)
            Icon { name: "bluetooth"; size: s(20); color: "#ffffff" }
            Text { text: selectedName || "Bluetooth"; color: "#ffffff"; font.pixelSize: 16 * ui; font.bold: true }
            Text { text: "Open the case near your PC to see battery"; color: "#9a9aa0"; font.pixelSize: 11 * ui }
        }

        Item {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: s(300)

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: s(10)

                // Power toggle switch
                Rectangle {
                    width: s(40); height: s(22); radius: s(11)
                    border.color: "#33ffffff"; border.width: s(1)
                    color: adapter && adapter.enabled ? "#3b8bff" : "#3a3a3e"
                    enabled: !!adapter && adapter.state !== BluetoothAdapterState.Blocked
                    Rectangle { width: s(18); height: s(18); radius: s(9); y: s(2); color: "#ffffff"
                                x: adapter && adapter.enabled ? parent.width - width - s(2) : s(2)
                                Behavior on x { NumberAnimation { duration: 120 } } }
                    MouseArea { anchors.fill: parent; onClicked: if (adapter) adapter.enabled = !adapter.enabled }
                }

                // Scan / Stop pill
                Pill { ui: bt.ui; id: scanPill
                    text: adapter && adapter.discovering ? "Stop" : "Scan"
                    visible: !!adapter && adapter.enabled && adapter.state !== BluetoothAdapterState.Blocked
                    onClicked: adapter.discovering = !adapter.discovering
                }

                // Refresh button
                Rectangle {
                    width: s(24); height: s(24); radius: s(12); color: "#1a1a1a"
                    border.color: "#33ffffff"; border.width: s(1)
                    Icon { anchors.centerIn: parent; name: "refresh-ccw"; size: s(14); color: "#9a9aa0" }
                    MouseArea { anchors.fill: parent; onClicked: if (adapter) adapter.discovering = !adapter.discovering }
                }

                // Unblock pill (rfkill)
                Pill { ui: bt.ui; id: unblockPill
                    text: "Unblock"
                    visible: !!adapter && adapter.state === BluetoothAdapterState.Blocked
                    onClicked: unblockRfkill()
                }

                // Bluetooth settings pill
                Pill { ui: bt.ui; id: settingsPill
                    text: "Bluetooth settings"
                    onClicked: Quickshell.execDetached(["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "bluetooth"])
                }

                // Bluetooth is off text (shown when off and not blocked)
                Text {
                    visible: !!adapter && !adapter.enabled && adapter.state !== BluetoothAdapterState.Blocked
                    text: "Bluetooth is off"
                    color: "#9a9aa0"
                    font.pixelSize: 11 * ui
                }
            }
        }
    }

    // ---- section label ----
    Text {
        id: sectionLabel
        text: "BLUETOOTH DEVICES"; color: "#9a9aa0"; font.pixelSize: 11 * ui; font.bold: true
        anchors.top: header.bottom; anchors.topMargin: s(16); anchors.left: parent.left
    }

    // ---- device list ----
    ListView {
        id: list
        anchors.top: sectionLabel.bottom; anchors.topMargin: s(8)
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        clip: true; spacing: s(4)
        model: bt.devices

        delegate: Item {
            width: ListView.view.width; height: s(48)
            Rectangle { anchors.fill: parent; radius: s(10); color: "#1a1a1a" }

            // left tap area: selects the device (shows in header)
            Item {
                id: selectArea
                width: parent.width - s(120); height: parent.height
                MouseArea { anchors.fill: parent; onClicked: bt.select(modelData.address, modelData.name) }
                Icon {
                    x: s(12); anchors.verticalCenter: parent.verticalCenter
                    name: "bluetooth"; size: s(16)
                    color: modelData.connected ? "#3b8bff" : "#9a9aa0"
                }
                Column {
                    x: s(38); anchors.verticalCenter: parent.verticalCenter; width: parent.width - s(160); spacing: s(1)
                    Text { text: modelData.name || modelData.address; color: "#ffffff"
                           font.pixelSize: 13 * ui; elide: Text.ElideRight }
                    Text { text: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                           color: "#9a9aa0"; font.pixelSize: 11 * ui; visible: modelData.batteryAvailable }
                }
            }

            Pill {
                ui: bt.ui
                anchors.right: parent.right; anchors.rightMargin: s(12); anchors.verticalCenter: parent.verticalCenter
                text: modelData.connected ? "Disconnect" : (modelData.connecting ? "Connecting..." : "Connect")
                enabled: !modelData.connecting
                onClicked: {
                    if (modelData.connected) modelData.disconnect()
                    else modelData.connect()
                    bt.select(modelData.address, modelData.name)
                }
            }
        }
    }

    // ---- empty states ----
    Text {
        anchors.centerIn: parent
        visible: !!adapter && adapter.state === BluetoothAdapterState.Blocked
        text: "Bluetooth blocked by rfkill"; color: "#9a9aa0"; font.pixelSize: 13 * ui
    }

    Text {
        anchors.centerIn: parent
        visible: !!adapter && adapter.enabled && devices.length === 0
        text: "No Bluetooth devices found"; color: "#9a9aa0"; font.pixelSize: 13 * ui
    }

    Text {
        anchors.centerIn: parent
        visible: !adapter
        text: "No Bluetooth adapter found"; color: "#9a9aa0"; font.pixelSize: 13 * ui
    }
}
