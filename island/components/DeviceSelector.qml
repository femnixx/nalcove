import QtQuick

Item {
    id: root
    property var model: []
    property var currentNode: null
    property bool opened: false
    signal picked(var node)

    function labelOf(n) { return n ? (n.description || n.nickname || n.name || "Unknown") : "No device" }
    function open() { opened = true }
    function close() { opened = false }

    width: parent ? parent.width : 200
    height: 32 + (opened ? list.height + 8 : 0)
    clip: true
    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    // Header
    Rectangle {
        id: header
        width: parent.width; height: 32; radius: 10; color: "#1a1a1a"
        Text {
            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 26
            text: root.labelOf(root.currentNode)
            color: "#ffffff"; font.pixelSize: 12
            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: root.opened ? "▴" : "▾"; color: "#9a9aa0"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { console.log("selector clicked, devices:", root.model ? root.model.length : -1); root.opened = !root.opened }
        }
    }

    // List
    Rectangle {
        y: 36
        width: parent.width
        height: list.height + 8
        radius: 10; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1
        visible: root.opened

        Column {
            id: list
            x: 4; y: 4
            width: parent.width - 8
            spacing: 2

            Text {
                visible: !root.model || root.model.length === 0
                text: "No devices found"; color: "#9a9aa0"; font.pixelSize: 12
                height: 30; verticalAlignment: Text.AlignVCenter; leftPadding: 10
            }

            Repeater {
                model: root.model
                delegate: Rectangle {
                    width: list.width; height: 30; radius: 8
                    property bool isCur: !!root.currentNode && modelData.name === root.currentNode.name
                    color: ma.containsMouse ? "#2a2a2a" : "transparent"
                    Text {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                        text: root.labelOf(modelData)
                        color: parent.isCur ? "#3b8bff" : "#ffffff"
                        font.pixelSize: 12; elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: { root.picked(modelData); root.opened = false }
                    }
                }
            }
        }
    }
}