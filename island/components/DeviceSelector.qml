import QtQuick
import QtQuick.Controls

Popup {
    id: root
    property var model: []
    property var currentNode: null
    property bool dropUp: false
    signal picked(var node)

    function labelOf(n) { return n ? (n.description || n.nickname || n.name) : "No device" }

    width: 200
    padding: 0
    topMargin: 4
    bottomMargin: 4
    leftMargin: 4
    rightMargin: 4

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
    }

    contentItem: Rectangle {
        id: content
        radius: 10
        color: "#1a1a1a"
        border.color: "#2a2a2a"
        border.width: 2

        Column {
            id: list
            spacing: 2
            Repeater {
                model: root.model
                delegate: Rectangle {
                    width: parent.width
                    height: 30
                    radius: 8
                    color: ma.containsMouse ? "#2a2a2a" : "#1a1a1a"
                    property bool isCur: root.currentNode && modelData.id === root.currentNode.id
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

    // Header button - external to popup
    Component.onCompleted: {
        if (root.currentNode) {
            // The header button is managed externally
        }
    }
}