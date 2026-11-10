import QtQuick

Rectangle {
    id: root
    property alias text: input.text
    property string placeholder: "Password"
    property bool revealed: false
    signal accepted()
    signal edited(string value)
    height: 32; radius: 10; color: "#1a1a1a"
    border.width: 1; border.color: input.activeFocus ? "#3b8bff" : "#2a2a2a"

    TextInput {
        id: input
        anchors.left: parent.left; anchors.leftMargin: 10
        anchors.right: eye.left; anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        color: "#ffffff"; font.pixelSize: 12; clip: true; selectByMouse: true
        echoMode: root.revealed ? TextInput.Normal : TextInput.Password
        onAccepted: root.accepted()
        onTextEdited: root.edited(text)
        Text { visible: input.text === ""; text: root.placeholder; color: "#66ffffff"; font.pixelSize: 12 }
    }
    Text {
        id: eye
        anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
        text: root.revealed ? "Hide" : "Show"; color: "#9a9aa0"; font.pixelSize: 11
        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: root.revealed = !root.revealed }
    }
}