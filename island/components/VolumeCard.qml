import QtQuick
import "../services" as Services

Rectangle {
    id: root
    radius: 18; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1

    property real maxHeight: 400
    property real explicitHeight: 0
    signal outputClicked()

    readonly property real spacing: 10
    readonly property real margins: 24

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: root.margins
        spacing: root.spacing

        // ---- Volume row ----
        Column {
            width: parent.width
            spacing: 6
            Text {
                text: "Output"
                color: "#9a9aa0"
                font.pixelSize: 10
                font.bold: true
            }
            Row {
                id: sliderRow
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
                    enabled: Services.Audio.sinkReady
                    onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                }
                Text {
                    width: 34; anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Services.Audio.sinkVolume * 100)
                    color: "#ffffff"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight
                }
            }
        }

        // ---- Device selector (overlay, floats on top within reserved space) ----
        DeviceSelector {
            id: outputSelector
            width: content.width
            maxDropdownHeight: outputSelector.itemHeight * 3 + outputSelector.listSpacing * 2 + outputSelector.listPadding
            model: Services.Audio.sinks
            currentNode: Services.Audio.sink
            onPicked: n => Services.Audio.setDefaultSink(n)
            overlayMode: true
        }
    }

    // Explicit height from parent (balanced split); otherwise fit slider + closed selector header.
    height: explicitHeight > 0 ? explicitHeight : margins * 2 + sliderRow.height + root.spacing + outputSelector.height
}
