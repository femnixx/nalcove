import QtQuick
import qs.components 1.0


Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string icon: "folder"
    property string text: "Nothing here"
    property string actionText: ""
    property var onAction: null

    Column {
        anchors.centerIn: parent
        spacing: Theme.s3

        Icon {
            name: root.icon
            size: 48
            color: Theme.dim
        }

        Text {
            text: root.text
            color: Theme.dim
            font.pixelSize: Theme.tBody
            font.family: Theme.fontFamily
            horizontalAlignment: Text.AlignHCenter
        }

        Pill {
            visible: root.actionText !== "" && root.onAction !== null
            text: root.actionText
            accent: true
            onClicked: root.onAction()
        }
    }
}