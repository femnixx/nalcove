import QtQuick

Item {
    id: root
    property var model: []
    property var currentNode: null
    property bool dropUp: false
    property bool open: false
    signal picked(var node)

    function labelOf(n) { return n ? (n.description || n.nickname || n.name) : "No device" }

    implicitWidth: 200
    implicitHeight: 32
    z: open ? 100 : 0

    Rectangle {
        id: header
        width: parent.width; height: 32; radius: 10; color: "#22ffffff"
        Text {
            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 26
            text: root.labelOf(root.currentNode)
            color: "#ffffff"; font.pixelSize: 12
            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
        }
        Text { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
               text: root.open ? "▴" : "▾"; color: "#9a9aa0" }
        MouseArea { anchors.fill: parent; onClicked: root.open = !root.open }
    }

    Rectangle {
        visible: root.open
        width: parent.width
        height: list.implicitHeight + 8
        y: root.dropUp ? -height - 4 : header.height + 4
        radius: 10; color: "#2a2a2e"; border.color: "#33ffffff"; border.width: 1

        Column {
            id: list
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
            spacing: 2
            Repeater {
                model: root.model
                delegate: Rectangle {
                    width: list.width; height: 30; radius: 8
                    color: ma.containsMouse ? "#22ffffff" : "transparent"
                    property bool isCur: root.currentNode && modelData.id === root.currentNode.id
                    Text {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                        text: root.labelOf(modelData)
                        color: parent.isCur ? "#3b8bff" : "#ffffff"; font.pixelSize: 12
                        elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        id: ma; anchors.fill: parent; hoverEnabled: true
                        onClicked: { root.picked(modelData); root.open = false }
                    }
                }
            }
        }
    }
}