import QtQuick
import qs.components 1.0

Item {
    anchors.fill: parent
    width: 700
    height: 800

    Component.onCompleted: console.log("ControlsTab loaded!")

    Rectangle {
        anchors.fill: parent
        color: "#2a2a2e"

        Text {
            anchors.centerIn: parent
            text: "CONTROLS TAB\nOutput + Input + Apps"
            color: "#ffffff"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignCenter
        }

        Card {
            x: 20; y: 20
            width: 300; height: 150
            cardFill: "#3a3a3a"
            cardBorderColor: "#ffffff"
            cardRadius: 10
        }
    }
}
