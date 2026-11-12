import QtQuick
import "../services" as Services

// Circular battery indicator with outer ring and gradient color:
//   >60%  green, <60% yellow, <=15% red, charged = blue
Rectangle {
    id: root
    property real ui: 1
    width: s(48); height: s(48)
    color: "transparent"

    function s(px) { return Math.round(px * ui) }

    // Compute battery color based on charge level
    readonly property color batteryColor: {
        if (!Services.Battery.ready) return "#30d158"          // AC power - green
        if (Services.Battery.full) return "#3b8bff"            // Fully charged - blue
        var pct = Services.Battery.pct * 100
        if (pct <= 15) return "#ff453a"                        // Low - red
        if (pct <= 60) return "#ffd60a"                        // Mid - yellow
        return "#30d158"                                       // Good - green
    }

    // Outer ring
    Rectangle {
        id: ring
        width: root.width; height: root.height
        radius: root.width / 2
        border.color: "#3a3a3a"
        border.width: s(2)
        color: "transparent"
        anchors.centerIn: parent
    }

    // Inner circle filled with battery color
    Rectangle {
        id: inner
        width: root.width - s(8); height: root.height - s(8)
        radius: inner.width / 2
        color: root.batteryColor
        anchors.centerIn: parent
    }

    // Percentage text (or "AC" when no battery)
    Text {
        id: pctText
        text: Services.Battery.ready ? Math.round(Services.Battery.pct * 100) + "%" : "AC"
        color: root.batteryColor
        font.pixelSize: 11 * ui
        font.bold: true
        anchors.centerIn: parent
    }

    // Charging indicator - small lightning bolt overlay when charging
    Item {
        id: chargingBolt
        anchors.centerIn: parent
        visible: Services.Battery.ready && Services.Battery.charging
        width: s(10); height: s(10)
        Text {
            anchors.fill: parent
            text: "\u26A1"
            font.pixelSize: 10 * ui
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
