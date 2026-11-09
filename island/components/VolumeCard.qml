import QtQuick
import "../services" as Services

Rectangle {
    radius: 18; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1

    signal outputClicked()

    Column {
        anchors.fill: parent; anchors.margins: 12; spacing: 10

        Row {
            width: parent.width; spacing: 10
            Item {
                width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
                Icon { name: "volume"; size: 18; anchors.centerIn: parent; opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }
                MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSinkMute() }
            }
            FlatSlider {
                width: parent.width - 22 - 34 - 20
                anchors.verticalCenter: parent.verticalCenter
                value: Services.Audio.sinkVolume
                onMoved: Services.Audio.setSinkVolume(value)
            }
            Text {
                width: 34; anchors.verticalCenter: parent.verticalCenter
                text: Math.round(Services.Audio.sinkVolume * 100)
                color: "#ffffff"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight
            }
        }

        // Device selector with popup
        Item {
            id: deviceSelectorWrapper
            width: parent.width
            height: 32

            Rectangle {
                id: headerBtn
                width: parent.width; height: 32; radius: 10; color: "#1a1a1a"
                Text {
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 26
                    text: outputSelector.labelOf(outputSelector.currentNode)
                    color: "#ffffff"; font.pixelSize: 12
                    elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
                       text: outputSelector.open ? "▴" : "▾"; color: "#9a9aa0" }
                MouseArea { anchors.fill: parent; onClicked: outputSelector.open ? outputSelector.close() : outputSelector.open() }
            }

            DeviceSelector {
                id: outputSelector
                width: parent.width
                model: Services.Audio.sinks
                currentNode: Services.Audio.sink
                onPicked: n => Services.Audio.setDefaultSink(n)
                // Position popup below the header button
                x: headerBtn.x
                y: headerBtn.y + headerBtn.height + 4
            }
        }
    }
}