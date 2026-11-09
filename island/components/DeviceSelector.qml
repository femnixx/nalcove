import QtQuick
import QtQuick.Controls

Popup {
    id: root
    property var model: []
    property var currentNode: null
    property bool dropUp: false
    signal picked(var node)

    function labelOf(n) { return n ? (n.description || n.nickname || n.name || "Unknown") : "No device" }

    width: parent ? parent.width : 200
    y: dropUp ? -height - 4 : (parent ? parent.height + 4 : 0)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 } }

    background: Item {}

    contentItem: Rectangle {
        radius: 10
        color: "#1a1a1a"
        border.color: "#2a2a2a"
        border.width: 1
        implicitHeight: list.implicitHeight + 8

        Column {
            id: list
            x: 4; y: 4
            width: parent.width - 8
            spacing: 2

            Repeater {
                model: root.model
                delegate: Rectangle {
                    width: list.width
                    height: 30
                    radius: 8
                    color: ma.containsMouse ? "#2a2a2a" : "transparent"
                    property bool isCur: root.currentNode !== null && modelData.id === root.currentNode.id

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: root.labelOf(modelData)
                        color: parent.isCur ? "#3b8bff" : "#ffffff"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { root.picked(modelData); root.close() }
                    }
                }
            }
        }
    }
}