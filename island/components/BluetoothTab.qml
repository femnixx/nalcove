import QtQuick
import Quickshell.Bluetooth

Item {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: Bluetooth.devices.values.filter(d => d.paired || d.connected)

    Row {
        id: header; spacing: 10; width: parent.width
        Text { text: "Bluetooth"; color: "#ffffff"; font.pixelSize: 15; font.bold: true
               anchors.verticalCenter: parent.verticalCenter }
        Rectangle {
            visible: root.adapter !== null
            width: 40; height: 22; radius: 11
            color: root.adapter && root.adapter.enabled ? "#3b8bff" : "#33ffffff"
            Rectangle { width: 18; height: 18; radius: 9; color: "#ffffff"; y: 2
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
    }

    ListView {
        anchors { top: header.bottom; topMargin: 10; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: root.devices
        spacing: 6; clip: true
        delegate: Rectangle {
            width: ListView.view.width; height: 40; radius: 10
            color: modelData.connected ? "#223b8bff" : "#16ffffff"
            Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                   width: parent.width - 90; elide: Text.ElideRight
                   text: modelData.name || modelData.address; color: "#ffffff"; font.pixelSize: 12 }
            Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                   color: "#9a9aa0"; font.pixelSize: 11
                   text: modelData.connected
                         ? (modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : "On")
                         : "Off" }
            MouseArea {
                anchors.fill: parent
                onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
            }
        }
    }

    Text { anchors.centerIn: parent
           visible: root.adapter === null || root.devices.length === 0
           color: "#66ffffff"; font.pixelSize: 12
           text: root.adapter === null ? "No Bluetooth adapter found" : "No paired devices" }
}