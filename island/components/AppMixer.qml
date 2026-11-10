import QtQuick
import Quickshell
import "../services" as Services

Column {
    id: mixer
    width: parent ? parent.width : 360
    spacing: 8
    visible: Services.Audio.appStreams.length > 0

    Text { text: "Applications"; color: "#9a9aa0"; font.pixelSize: 11; font.bold: true }

    Repeater {
        model: Services.Audio.appStreams
        delegate: Item {
            id: row
            required property var modelData
            readonly property var node: modelData
            width: mixer.width
            height: 44

            Image {
                id: appIcon
                x: 0; anchors.verticalCenter: parent.verticalCenter
                width: 28; height: 28
                sourceSize: Qt.size(56, 56)
                asynchronous: true
                source: Quickshell.iconPath(Services.Audio.appIconName(row.node), "audio-x-generic")
                opacity: row.node.audio && row.node.audio.muted ? 0.4 : 1
                MouseArea { anchors.fill: parent; onClicked: Services.Audio.toggleNodeMute(row.node) }
            }

            Column {
                id: labels
                anchors.left: appIcon.right; anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 110
                spacing: 1
                Text { width: parent.width; text: Services.Audio.appName(row.node); color: "#ffffff"; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight }
                Text { width: parent.width; text: Services.Audio.appDetail(row.node); color: "#9a9aa0"; font.pixelSize: 10; elide: Text.ElideRight; visible: text !== "" }
            }

            FlatSlider {
                anchors.left: labels.right; anchors.leftMargin: 10
                anchors.right: pct.left; anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                value: row.node.audio ? row.node.audio.volume : 0
                enabled: row.node.audio !== null
                onMoved: Services.Audio.setNodeVolume(row.node, value)
            }

            Text {
                id: pct
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                width: 34; horizontalAlignment: Text.AlignRight
                text: row.node.audio ? Math.round(row.node.audio.volume * 100) : 0
                color: "#ffffff"; font.pixelSize: 12
            }
        }
    }
}