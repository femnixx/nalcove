import QtQuick
import qs.components 1.0
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth


Item {
    id: bt
    readonly property var adapter: Bluetooth.defaultAdapter

    property string expandedAddr: ""
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

    Column {
        anchors.fill: parent
        spacing: Theme.s2

        // ---- header ----
        RowLayout {
            Layout.fillWidth: true
            height: Theme.rowH
            spacing: Theme.s2

            Text {
                text: "Bluetooth"
                font.pixelSize: Theme.tTitle
                font.bold: true
                font.family: Theme.fontFamily
                color: Theme.fg
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Switch {
                visible: root.adapter !== null
                checked: root.adapter && root.adapter.enabled
                onToggled: root.adapter.enabled = checked
                Layout.alignment: Qt.AlignVCenter
            }

            Pill {
                visible: root.adapter && root.adapter.enabled
                text: root.adapter && root.adapter.discovering ? "Stop" : "Scan"
                Layout.alignment: Qt.AlignVCenter
                onClicked: root.adapter.discovering = !root.adapter.discovering
            }

            Pill {
                text: root.width > 520 ? "GNOME settings" : ""
                icon: "settings"
                iconOnly: root.width <= 520
                tooltip: "GNOME settings"
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached(["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "bluetooth"])
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !bt.adapter
            text: "No Bluetooth adapter found"
            color: Theme.dim
            font.pixelSize: Theme.tBody
            font.family: Theme.fontFamily
        }

        ListView {
            anchors.fill: parent
            visible: bt.adapter && bt.adapter.enabled
            clip: true; spacing: 4; reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            model: bt.devices

            delegate: Item {
                id: row
                required property var modelData
                readonly property var dev: modelData
                readonly property bool expanded: bt.expandedAddr === dev.address
                width: ListView.view.width
                height: head.height + (expanded ? detail.implicitHeight + 10 : 0)
                clip: true
                Behavior on height { NumberAnimation { duration: 140; easing.type: Theme.easingOutCubic } }

                Card {
                    anchors.fill: parent
                    hoverEnabled: false
                }

                Item {
                    id: head
                    width: parent.width; height: 44
                    Icon { x: Theme.s4; anchors.verticalCenter: parent.verticalCenter; name: "bluetooth"; size: Theme.iconMd
                           color: row.dev.connected ? Theme.accent : Theme.dim }
                    Column {
                        x: Theme.s4 * 3; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 180; spacing: 1
                        Text { width: parent.width; text: row.dev.name || row.dev.address; color: Theme.fg; font.pixelSize: Theme.tBody; font.family: Theme.fontFamily; elide: Text.ElideRight }
                        Text { text: row.dev.connected ? "Connected" : row.dev.paired ? "Paired" : "Available"
                               color: row.dev.connected ? Theme.accent : Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                    }
                    Row {
                        anchors.right: parent.right; anchors.rightMargin: Theme.s4; anchors.verticalCenter: parent.verticalCenter; spacing: Theme.s2
                        Text { visible: row.dev.batteryAvailable; text: Math.round(row.dev.battery * 100) + "%"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
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
                    MouseArea { anchors.fill: parent; anchors.rightMargin: 140; onClicked: bt.toggle(row.dev.address, row.dev.name) }
                }

                Column {
                    id: detail
                    anchors.top: head.bottom
                    x: Theme.s4; width: parent.width - Theme.s4 * 2; spacing: Theme.s2
                    visible: row.expanded

                    Text { text: "Name"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.family: Theme.fontFamily }
                    Row {
                        spacing: Theme.s2; width: parent.width
                        Rectangle {
                            width: parent.width - 90; height: Theme.controlH; radius: Theme.rMd; color: "#111113"
                            border.width: 1; border.color: renameInput.activeFocus ? Theme.accent : Theme.cardBorder
                            TextInput {
                                id: renameInput
                                anchors.fill: parent; anchors.leftMargin: Theme.s3; anchors.rightMargin: Theme.s3
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.fg; font.pixelSize: Theme.tBody; font.family: Theme.fontFamily; clip: true; selectByMouse: true
                                text: bt.renameDraft
                                onTextEdited: bt.renameDraft = text
                                onAccepted: if (text.trim() !== "") row.dev.name = text.trim()
                            }
                        }
                        Pill { text: "Rename"; onClicked: if (bt.renameDraft.trim() !== "") row.dev.name = bt.renameDraft.trim() }
                    }
                    Text { text: row.dev.address; color: Theme.faint; font.pixelSize: Theme.tCaption; font.family: Theme.fontFamily }
                    Flow {
                        width: parent.width; spacing: Theme.s2
                        Pill { text: row.dev.trusted ? "Trusted ✓" : "Trust"; onClicked: row.dev.trusted = !row.dev.trusted }
                        Pill { text: "Forget"; danger: true; visible: row.dev.paired
                               onClicked: { row.dev.forget(); bt.toggle(row.dev.address, "") } }
                    }
                    Item { width: 1; height: Theme.s1 }
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: bt.adapter && bt.adapter.enabled && bt.devices.length === 0
            icon: "bluetooth"
            text: "No devices found"
        }
    }
}