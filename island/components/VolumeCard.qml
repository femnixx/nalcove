import QtQuick
import QtQuick.Layouts
import "../services" as Services


Card {
    id: root
    hoverEnabled: false
    Layout.fillWidth: true

    signal outputClicked()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        // Output volume row
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: Theme.controlH
            Layout.preferredHeight: Theme.controlH
            spacing: Theme.s2

            Item {
                width: Theme.iconMd + Theme.s2; height: Theme.controlH
                Icon { name: "volume"; size: Theme.iconMd; anchors.centerIn: parent; opacity: Services.Audio.sinkMuted ? 0.5 : 1.0 }
                MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleSinkMute() }
            }

            FlatSlider {
                Layout.fillWidth: true
                value: Services.Audio.sinkVolume
                enabled: Services.Audio.sinkReady
                onMoved: if (Services.Audio.sinkReady) Services.Audio.setSinkVolume(value)
            }

            Text {
                width: 34
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                text: Math.round(Services.Audio.sinkVolume * 100)
                color: Theme.fg
                font.pixelSize: Theme.tBody
                font.family: Theme.fontFamily
            }
        }

        // Output device selector
        DeviceSelector {
            id: outputSelector
            Layout.fillWidth: true
            accordionGroup: true
            model: Services.Audio.sinks
            currentNode: Services.Audio.sink
            onPicked: n => Services.Audio.setDefaultSink(n)
        }
    }
}