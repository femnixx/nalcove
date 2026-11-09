import QtQuick
import "../services" as Services

Rectangle {
    radius: 18; color: "#16ffffff"; border.color: "#22ffffff"; border.width: 1
    visible: Services.Brightness.available

    Row {
        anchors.fill: parent; anchors.margins: 12; spacing: 10
        Icon { name: "sun"; size: 18; anchors.verticalCenter: parent.verticalCenter }
        FlatSlider {
            width: parent.width - 18 - 34 - 20
            anchors.verticalCenter: parent.verticalCenter
            value: Services.Brightness.level
            onMoved: Services.Brightness.set(value)
        }
        Text {
            width: 34; anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Services.Brightness.level * 100)
            color: "#ffffff"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight
        }
    }
}