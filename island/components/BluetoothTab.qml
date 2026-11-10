import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: bt
    readonly property var adapter: Bluetooth.defaultAdapter

    property string expandedAddr: ""     // UI state keyed by address, outside delegates
    property string renameDraft: ""

    // connected first, then paired, then by name. Re-evaluates when any state changes.
    readonly property var devices: {
        if (!adapter) return []
        var list = adapter.devices.values.slice()
        list.sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired)
                            || (a.name || "").localeCompare(b.name || ""))
        return list
    }

    function toggle(addr, name) {
        expandedAddr = expandedAddr === addr ? "" : addr
        renameDraft = name || ""
    }

    // Scanning drains power and radio time, so stop automatically
    function scan() { if (adapter) { adapter.discovering = true; scanStop.restart() } }
    Timer { id: scanStop; interval: 12000; onTriggered: if (bt.adapter) bt.adapter.discovering = false }
    Component.onDestruction: if (adapter) adapter.discovering = false

    Row {
        id: header
        width: parent.width; height: 32; spacing: 10
        Text { text: "Bluetooth"; color: "#ffffff"; font.pixelSize: 16; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
        Item { width: parent.width - 300; height: 1 }
        Rectangle {
            visible: root.adapter !== null
            width: 40; height: 22; radius: 11
            color: root.adapter && root.adapter.enabled ? "#3b8bff" : "#3a3a3e"
            Rectangle { width: 18; height: 18; radius: 9; y: 2; color: "#ffffff"
                        x: root.adapter && root.adapter.enabled ? parent.width - width - 2 : 2
                        Behavior on x { NumberAnimation { duration: 120 } } }
            MouseArea { anchors.fill: parent; onClicked: root.adapter.enabled = !root.adapter.enabled }
        }
        Rectangle {
            visible: root.adapter && root.adapter.enabled
            width: 60; height: 22; radius: 11; color: "#22ffffff"
            Text { anchors.centerIn: parent; color: "#ffffff"; font.pixelSize: 11
                   text: root.adapter && root.adapter.discovering ? "Stop" : "Scan" }
            MouseArea { anchors.fill: parent; onClicked: root.adapter.discovering = !root.adapter.discovering }
        }
        Pill { text: "GNOME settings"; anchors.verticalCenter: parent.verticalCenter
               onClicked: Quickshell.execDetached(["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "bluetooth"]) }
    }

    Text {
        anchors.centerIn: parent
        visible: !bt.adapter
        text: "No Bluetooth adapter found"; color: "#9a9aa0"; font.pixelSize: 13
    }

    ListView {
        anchors.top: header.bottom; anchors.topMargin: 10
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        clip: true; spacing: 4; reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        visible: bt.adapter && bt.adapter.enabled
        model: bt.devices

        delegate: Item {
            id: row
            required property var modelData
            readonly property var dev: modelData
            readonly property bool expanded: bt.expandedAddr === dev.address
            width: ListView.view.width
            height: head.height + (expanded ? detail.implicitHeight + 10 : 0)
            clip: true
            Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            Rectangle { anchors.fill: parent; radius: 10; color: "#1a1a1a" }

            Item {
                id: head
                width: parent.width; height: 44
                Icon { x: 12; anchors.verticalCenter: parent.verticalCenter; name: "bluetooth"; size: 16
                       color: row.dev.connected ? "#3b8bff" : "#9a9aa0" }
                Column {
                    x: 38; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 160; spacing: 1
                    Text { width: parent.width; text: row.dev.name || row.dev.address; color: "#ffffff"; font.pixelSize: 12; elide: Text.ElideRight }
                    Text { text: row.dev.connected ? "Connected" : row.dev.paired ? "Paired" : "Available"
                           color: row.dev.connected ? "#3b8bff" : "#9a9aa0"; font.pixelSize: 10 }
                }
                Row {
                    anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                    Text { visible: row.dev.batteryAvailable; text: Math.round(row.dev.battery * 100) + "%"; color: "#9a9aa0"; font.pixelSize: 11 }
                    Pill {
                        text: row.dev.connected ? "Disconnect" : row.dev.paired ? "Connect" : "Pair"
                        accent: !row.dev.connected
                        onClicked: {
                            if (row.dev.connected) row.dev.disconnect()
                            else if (row.dev.paired) row.dev.connect()
                            else { row.dev.pair(); row.dev.trusted = true }
                        }
                    }
                }
                MouseArea { anchors.fill: parent; anchors.rightMargin: 120; onClicked: bt.toggle(row.dev.address, row.dev.name) }
            }

            Column {
                id: detail
                anchors.top: head.bottom
                x: 12; width: parent.width - 24; spacing: 8
                visible: row.expanded

                Text { text: "Name"; color: "#9a9aa0"; font.pixelSize: 11 }
                Row {
                    spacing: 6; width: parent.width
                    Rectangle {
                        width: parent.width - 90; height: 32; radius: 10; color: "#111113"
                        border.width: 1; border.color: renameInput.activeFocus ? "#3b8bff" : "#2a2a2a"
                        TextInput {
                            id: renameInput
                            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#ffffff"; font.pixelSize: 12; clip: true; selectByMouse: true
                            text: bt.renameDraft
                            onTextEdited: bt.renameDraft = text
                            onAccepted: if (text.trim() !== "") row.dev.name = text.trim()
                        }
                    }
                    Pill { text: "Rename"; onClicked: if (bt.renameDraft.trim() !== "") row.dev.name = bt.renameDraft.trim() }
                }
                Text { text: row.dev.address; color: "#66ffffff"; font.pixelSize: 10 }
                Flow {
                    width: parent.width; spacing: 6
                    Pill { text: row.dev.trusted ? "Trusted ✓" : "Trust"; onClicked: row.dev.trusted = !row.dev.trusted }
                    Pill { text: "Forget"; danger: true; visible: row.dev.paired
                           onClicked: { row.dev.forget(); bt.toggle(row.dev.address, "") } }
                }
                Item { width: 1; height: 2 }
            }
        }
    }
}