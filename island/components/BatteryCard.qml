import QtQuick
import "../services" as Services
import Quickshell.Services.UPower

Rectangle {
    id: root
    implicitWidth: 100; implicitHeight: 120
    color: "#1a1a1a"
    border.color: "#2a2a2e"
    border.width: 1
    radius: 18

    readonly property var dev: UPower.displayDevice
    readonly property real pct: dev && dev.ready ? dev.percentage : 0     // 0..1
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: dev && dev.state === UPowerDeviceState.FullyCharged
    readonly property bool low: !charging && pct <= 0.20
    readonly property color accent: charging || full ? "#30d158"
        : low ? "#ff453a" : pct <= 0.35 ? "#ffd60a" : "#ffffff"

    function fmt(sec) {
        if (!sec || sec <= 0) return ""
        const h = Math.floor(sec / 3600), m = Math.floor((sec % 3600) / 60)
        return h > 0 ? h + "h " + m + "m" : m + "m"
    }
    readonly property string status: {
        if (!dev || !dev.ready) return "No battery"
        if (full) return "Fully charged"
        if (charging) return fmt(dev.timeToFull) ? fmt(dev.timeToFull) + " to full" : "Charging"
        if (low) return "Low battery"
        return fmt(dev.timeToEmpty) ? fmt(dev.timeToEmpty) + " left" : "On battery"
    }

    Column {
        anchors.centerIn: parent
        spacing: 6

        // Circular battery indicator
        Rectangle {
            width: 72; height: 72
            radius: 36
            color: "#1a1a1a"
            border.color: "#2a2a2e"
            border.width: 1

            // Percentage text in center
            Text {
                anchors.centerIn: parent
                text: Math.round(pct * 100) + "%"
                color: accent
                font.pixelSize: 20
                font.bold: true
            }

            // Ring around circle representing percentage
            // Draw as a rotated rectangle arc approximation using multiple segments
            // For simplicity, draw a partial circle border
            Item {
                anchors.fill: parent
                anchors.margins: 6
                // Ring segments drawn via rotated rectangles
                Repeater {
                    model: 100
                    delegate: Rectangle {
                        width: 5; height: parent.height * 0.9
                        color: index < Math.round(pct * 100) ? accent : "#2a2a2e"
                        radius: 2
                        rotation: index * 3.6
                        transformOrigin: Item.Center
                        anchors.centerIn: parent
                    }
                }
            }
        }

        // Duration below
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: status
            color: "#9a9aa0"; font.pixelSize: 10
        }
    }
}
