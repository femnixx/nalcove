import QtQuick

Item {
    id: root
    property var model: []
    property var currentNode: null
    property bool opened: false
    property real maxDropdownHeight: 200
    signal picked(var node)

    readonly property int maxVisibleItems: 3
    readonly property int itemHeight: 30
    readonly property int listSpacing: 2
    readonly property int listPadding: 8

    function labelOf(n) { return n ? (n.description || n.nickname || n.name || "Unknown") : "No device" }
    function open() { opened = true }
    function close() { opened = false }

    width: parent ? parent.width : 200
    height: header.height + (opened ? listColumn.implicitHeight : 0)
    clip: true

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
            onClicked: { root.opened = !root.opened }
        }
    }

    // List column - expands when opened
    Column {
        id: listColumn
        y: header.height
        width: parent.width
        spacing: root.listSpacing
        visible: root.opened

        Rectangle {
            id: dropdownBg
            width: parent.width
            height: flickable.visible ? flickable.height : staticList.implicitHeight + 8
            radius: 10; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1
            clip: true

            // Scrollable list for many items (>3)
            Flickable {
                id: flickable
                x: 4; y: 4
                width: parent.width - 8
                contentWidth: parent.width - 8
                contentHeight: list.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                visible: root.model && root.model.length > root.maxVisibleItems
                height: Math.min(list.height, root.maxDropdownHeight - 8)

                Column {
                    id: list
                    width: flickable.contentWidth
                    spacing: root.listSpacing

                    Text {
                        visible: !root.model || root.model.length === 0
                        text: "No devices found"; color: "#9a9aa0"; font.pixelSize: 12
                        height: 30; verticalAlignment: Text.AlignVCenter; leftPadding: 10
                    }

                    Repeater {
                        model: root.model
                        delegate: Rectangle {
                            width: list.width; height: root.itemHeight; radius: 8
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

            // Non-scrollable list for few items (≤3)
            Column {
                id: staticList
                x: 4; y: 4
                width: parent.width - 8
                spacing: root.listSpacing
                visible: !flickable.visible

                Text {
                    visible: !root.model || root.model.length === 0
                    text: "No devices found"; color: "#9a9aa0"; font.pixelSize: 12
                    height: 30; verticalAlignment: Text.AlignVCenter; leftPadding: 10
                }

                Repeater {
                    model: root.model
                    delegate: Rectangle {
                        width: staticList.width; height: root.itemHeight; radius: 8
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
}