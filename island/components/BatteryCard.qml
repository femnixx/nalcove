import QtQuick
import Quickshell.Services.UPower

Rectangle {
    id: card
    implicitWidth: 150; implicitHeight: 110
    radius: 18
    color: "#16ffffff"
    border.color: "#22ffffff"; border.width: 1

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
        spacing: 8

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Rectangle {
                width: 56; height: 26; radius: 7
                color: "transparent"; border.color: "#aaffffff"; border.width: 2
                Rectangle {
                    x: 3; y: 3; height: parent.height - 6; radius: 4
                    width: Math.max(4, (parent.width - 6) * card.pct)
                    color: card.accent
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
                Text {
                    anchors.centerIn: parent
                    visible: card.charging
                    text: "⚡"; font.pixelSize: 14; color: "#000000"
                }
            }
            Rectangle { width: 3; height: 10; radius: 1; color: "#aaffffff"; anchors.verticalCenter: parent.verticalCenter }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(card.pct * 100) + "%"
            color: card.accent; font.pixelSize: 22; font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: card.status
            color: "#9a9aa0"; font.pixelSize: 11
        }
    }
}