import QtQuick

Rectangle {
    id: root
    property string text: ""
    property bool accent: false
    property bool danger: false
    property bool busy: false
    signal clicked()
    implicitWidth: label.implicitWidth + 24
    height: 28; radius: 14
    opacity: enabled ? 1 : 0.5
    color: danger ? (ma.containsMouse ? "#ff453a" : "#33ff453a")
         : accent ? (ma.containsMouse ? "#5aa0ff" : "#3b8bff")
         : (ma.containsMouse ? "#2a2a2e" : "#1f1f22")
    Text { id: label; anchors.centerIn: parent; text: root.busy ? "…" : root.text; color: "#ffffff"; font.pixelSize: 12 }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; enabled: root.enabled && !root.busy; onClicked: root.clicked() }
}