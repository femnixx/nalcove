import QtQuick
import "../services" as Services

Rectangle {
    id: root
    property real ui: 1
    radius: s(18); color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: s(1)

    function s(px) { return Math.round(px * ui) }

    readonly property real spacing: s(10)
    readonly property real margins: s(24)

    height: margins * 2 + brightnessRow.height

    Column {
        id: content
        anchors.centerIn: parent
        width: parent.width - root.margins * 2
        spacing: s(6)

        Text {
            text: "Brightness"
            color: "#9a9aa0"
            font.pixelSize: 10 * ui
            font.bold: true
        }

        Row {
            id: brightnessRow
            width: parent.width; spacing: s(10)
            height: s(22)
            Icon { name: "sun"; size: s(18); anchors.verticalCenter: parent.verticalCenter }
            FlatSlider {
                ui: root.ui
                width: parent.width - s(18) - s(34) - s(20)
                anchors.verticalCenter: parent.verticalCenter
                value: Services.Brightness.level
                onMoved: Services.Brightness.set(value)
            }
            Text {
                width: s(34); anchors.verticalCenter: parent.verticalCenter
                text: Math.round(Services.Brightness.level * 100)
                color: "#ffffff"; font.pixelSize: 12 * ui; horizontalAlignment: Text.AlignRight
            }
        }
    }
}
