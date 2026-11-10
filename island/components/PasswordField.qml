import QtQuick
import qs.components as Theme
import ".." 1.0 as Theme

Rectangle {
    id: root
    property alias text: input.text
    property string placeholder: "Password"
    property bool revealed: false
    signal accepted()
    signal edited(string value)
    height: Theme.controlH
    radius: Theme.rMd
    color: Theme.card
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.cardBorder

    TextInput {
        id: input
        anchors.left: parent.left
        anchors.leftMargin: Theme.s3
        anchors.right: eye.left
        anchors.rightMargin: Theme.s2
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.fg
        font.pixelSize: Theme.tBody
        font.family: Theme.fontFamily
        clip: true
        selectByMouse: true
        echoMode: root.revealed ? TextInput.Normal : TextInput.Password
        onAccepted: root.accepted()
        onTextEdited: root.edited(text)
        Text {
            visible: input.text === ""
            text: root.placeholder
            color: Theme.faint
            font.pixelSize: Theme.tBody
            font.family: Theme.fontFamily
        }
    }

    Text {
        id: eye
        anchors.right: parent.right
        anchors.rightMargin: Theme.s3
        anchors.verticalCenter: parent.verticalCenter
        text: root.revealed ? "Hide" : "Show"
        color: Theme.dim
        font.pixelSize: Theme.tSmall
        font.family: Theme.fontFamily
        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            onClicked: root.revealed = !root.revealed
        }
    }
}