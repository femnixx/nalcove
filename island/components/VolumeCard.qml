import QtQuick
import "../services" as Services

Rectangle {
    id: root
    radius: 18; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1
    clip: true

    property real maxHeight: 400
    signal outputClicked()

    readonly property real spacing: 10
    readonly property real margins: 24

    readonly property real brightnessHeight: Services.Brightness.available ? brightnessRow.implicitHeight : 0

    // Fixed card height - volume slider + brightness only. Dropdown opens as overlay on top.
    height: Math.min(margins * 2
        + sliderRow.height + spacing
        + brightnessHeight,
        maxHeight)

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: root.margins
        spacing: root.spacing

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

        // Device selector header - inline, dropdown opens as overlay below
        DeviceSelector {
            id: outputSelector
            width: content.width
            maxDropdownHeight: Math.max(40,
                (root.parent.height > 0 ? root.parent.height - 24 : maxHeight)
                - margins * 2 - sliderRow.height - brightnessHeight - root.spacing * 3 - 12)
            model: Services.Audio.sinks
            currentNode: Services.Audio.sink
            onPicked: n => Services.Audio.setDefaultSink(n)
            // Overlay mode: dropdown floats on top instead of pushing content down
            overlayMode: true
        }

        Row {
            id: brightnessRow
            visible: Services.Brightness.available
            width: parent.width; spacing: 10
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
