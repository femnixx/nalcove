import QtQuick
import qs.components as Theme
import QtQuick.Layouts
import "../services" as Services


Card {
    id: root
    hoverEnabled: false
    Layout.fillWidth: true
    visible: Services.Brightness.available

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: Theme.controlH
            Layout.preferredHeight: Theme.controlH
            spacing: Theme.s2

            Item {
                width: Theme.iconMd + Theme.s2; height: Theme.controlH
                Icon { name: "sun"; size: Theme.iconMd; anchors.centerIn: parent; color: Theme.fg }
            }

            FlatSlider {
                Layout.fillWidth: true
                value: Services.Brightness.level
                onMoved: Services.Brightness.set(value)
            }

            Text {
                width: 34
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                text: Math.round(Services.Brightness.level * 100)
                color: Theme.fg
                font.pixelSize: Theme.tBody
                font.family: Theme.fontFamily
            }
        }
    }
}