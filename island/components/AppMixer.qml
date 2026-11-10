import QtQuick
import qs.components 1.0
import Quickshell
import "../services" as Services


Column {
    id: mixer
    width: parent ? parent.width : 360
    spacing: Theme.s2
    visible: Services.Audio.appStreams.length > 0

    Text { text: "Applications"; color: Theme.dim; font.pixelSize: Theme.tSmall; font.bold: true; font.family: Theme.fontFamily }

    Repeater {
        model: Services.Audio.appStreams
        delegate: Item {
            id: row
            required property var modelData
            readonly property var node: modelData
            width: mixer.width
            height: Theme.controlH

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
                anchors.left: appIcon.right; anchors.leftMargin: Theme.s3
                anchors.verticalCenter: parent.verticalCenter
                width: 110
                spacing: 1
                Text { width: parent.width; text: Services.Audio.appName(row.node); color: Theme.fg; font.pixelSize: Theme.tBody; font.family: Theme.fontFamily; font.bold: true; elide: Text.ElideRight }
                Text { width: parent.width; text: Services.Audio.appDetail(row.node); color: Theme.dim; font.pixelSize: Theme.tCaption; font.family: Theme.fontFamily; elide: Text.ElideRight; visible: text !== "" }
            }

            FlatSlider {
                anchors.left: labels.right; anchors.leftMargin: Theme.s3
                anchors.right: pct.left; anchors.rightMargin: Theme.s3
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
                color: Theme.fg
                font.pixelSize: Theme.tBody
                font.family: Theme.fontFamily
            }
        }
    }
}