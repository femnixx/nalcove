import QtQuick
import "../services" as Services

Rectangle {
    id: root
    radius: 18; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1

    readonly property real spacing: 10
    readonly property real margins: 24

    height: margins * 2 + brightnessRow.height

    Column {
        id: content
        anchors.centerIn: parent
        width: parent.width - root.margins * 2
        spacing: 6

        Text {
            text: "Brightness"
            color: "#9a9aa0"
            font.pixelSize: 10
            font.bold: true
        }

        Row {
            id: brightnessRow
            width: parent.width; spacing: 10
            height: 22
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
}
