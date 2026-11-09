import QtQuick

Row {
    spacing: 6
    Icon { visible: Battery.charging; name: "zap"; size: 12; color: Battery.accent; anchors.verticalCenter: parent.verticalCenter }
    Text { text: Math.round(Battery.pct * 100) + "%"; color: Battery.accent; font.pixelSize: 12; font.bold: true
           anchors.verticalCenter: parent.verticalCenter }
}