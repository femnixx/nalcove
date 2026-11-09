pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    readonly property var dev: UPower.displayDevice
    readonly property bool ready: dev && dev.ready
    readonly property real pct: ready ? dev.percentage : 0          // 0..1
    readonly property bool charging: ready && dev.state === UPowerDeviceState.Charging
    readonly property bool full: ready && dev.state === UPowerDeviceState.FullyCharged
    readonly property bool low: ready && !charging && pct <= 0.20
    readonly property color accent: charging || full ? "#30d158"
        : low ? "#ff453a" : pct <= 0.35 ? "#ffd60a" : "#ffffff"

    function fmt(sec) {
        if (!sec || sec <= 0) return ""
        const h = Math.floor(sec / 3600), m = Math.floor((sec % 3600) / 60)
        return h > 0 ? h + "h " + m + "m" : m + "m"
    }
    readonly property string status: {
        if (!ready) return "No battery"
        if (full) return "Fully charged"
        if (charging) return fmt(dev.timeToFull) ? fmt(dev.timeToFull) + " to full" : "Charging"
        if (low) return "Low battery"
        return fmt(dev.timeToEmpty) ? fmt(dev.timeToEmpty) + " left" : "On battery"
    }
}