import QtQuick
import "../services" as Services

Rectangle {
    id: root
    radius: 18; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1
    // No clip - dropdown can extend below card boundary
    property real maxHeight: 400
    signal outputClicked()

    readonly property real spacing: 10
    readonly property real margins: 24

    // Always show brightness
    readonly property real brightnessHeight: brightnessRow.implicitHeight

    // Size naturally to content; grows to fit dropdown when open
    implicitHeight: margins * 2
        + sliderRow.height + spacing
        + brightnessHeight
    height: implicitHeight

    Column {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
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

        // Device selector - inline, dropdown extends card downward when open
        DeviceSelector {
            id: outputSelector
            width: content.width
            maxDropdownHeight: Math.max(40,
                (parent.height > 0 ? parent.height : maxHeight)
                - margins * 2 - sliderRow.height - brightnessHeight - root.spacing * 3 - 12)
            model: Services.Audio.sinks
            currentNode: Services.Audio.sink
            onPicked: n => Services.Audio.setDefaultSink(n)
            overlayMode: false
        }

        Row {
            id: brightnessRow
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
