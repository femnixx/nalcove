import QtQuick


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
        spacing: Style.s3

        Icon {
            name: root.icon
            size: 48
            color: Style.dim
        }

        Text {
            text: root.text
            color: Style.dim
            font.pixelSize: Style.tBody
            font.family: Style.fontFamily
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