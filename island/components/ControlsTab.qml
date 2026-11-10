import QtQuick
import "../services" as Services

Item {
    // Main content area - Flickable for scrolling
    Flickable {
        anchors.fill: parent
        contentWidth: 360
        contentHeight: contentColumn.implicitHeight
        clip: true

        Column {
            id: contentColumn
            width: 360
            spacing: 10

            // Output section
            Text { text: "Output"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }
            Row {
                width: parent.width; spacing: 10
                Item { width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
                    Icon { name: "volume"; size: 18; anchors.centerIn: parent; opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }
                    MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSinkMute() } }
                FlatSlider { 
                    width: parent.width - 22 - 34 - 20; anchors.verticalCenter: parent.verticalCenter
                    value: Services.Audio.sinkVolume
                    enabled: Services.Audio.sinkReady
                    onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
                }
                Text { width: 34; anchors.verticalCenter: parent.verticalCenter
                       text: Math.round(Services.Audio.sinkVolume * 100); color: "#ffffff"; font.pixelSize: 12
                       horizontalAlignment: Text.AlignRight }
            }

            DeviceSelector {
                id: outputSelector
                model: Services.Audio.sinks
                currentNode: Services.Audio.sink
                onPicked: n => Services.Audio.setDefaultSink(n)
            }

            Item { width: 1; height: 6 }

            // Input section
            Text { text: "Input"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }
            Row {
                width: parent.width; spacing: 10
                Item { width: 22; height: 22; anchors.verticalCenter: parent.verticalCenter
                    Icon { name: "volume"; size: 18; color: Services.Audio.sourceMuted ? "#ff453a" : "#ffffff"; anchors.centerIn: parent }
                    MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSourceMute() } }
                FlatSlider { 
                    width: parent.width - 22 - 34 - 20; anchors.verticalCenter: parent.verticalCenter
                    value: Services.Audio.sourceVolume
                    enabled: Services.Audio.sourceReady
                    onMoved: if (Services.Audio.sourceReady) Services.Audio.setSourceVolume(value)
                }
                Text { width: 34; anchors.verticalCenter: parent.verticalCenter
                       text: Math.round(Services.Audio.sourceVolume * 100); color: "#ffffff"; font.pixelSize: 12
                       horizontalAlignment: Text.AlignRight }
            }

            DeviceSelector {
                id: inputSelector
                model: Services.Audio.sources
                currentNode: Services.Audio.source
                onPicked: n => Services.Audio.setDefaultSource(n)
            }

            Item { width: 1; height: 6; visible: Services.Brightness.available }

            // Per-app volume mixer
            AppMixer { width: parent.width }

            Item { width: 1; height: 6; visible: Services.Brightness.available }

            Text { visible: Services.Brightness.available; text: "Brightness"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }
            Row {
                visible: Services.Brightness.available
                width: parent.width; spacing: 10
                Icon { name: "sun"; size: 18; anchors.verticalCenter: parent.verticalCenter }
                FlatSlider { width: parent.width - 18 - 34 - 20; anchors.verticalCenter: parent.verticalCenter
                             value: Services.Brightness.level; onMoved: Services.Brightness.set(value) }
                Text { width: 34; anchors.verticalCenter: parent.verticalCenter
                       text: Math.round(Services.Brightness.level * 100); color: "#ffffff"; font.pixelSize: 12
                       horizontalAlignment: Text.AlignRight }
            }
        }
    }
}