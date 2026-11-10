import QtQuick

Item {
    id: root
    property var model: []
    property var currentNode: null
    property bool opened: false
    property real maxDropdownHeight: root.itemHeight * 4 + root.listSpacing * 3 + root.listPadding
    property bool overlayMode: false
    signal picked(var node)

    readonly property int itemHeight: 30
    readonly property int listSpacing: 2
    readonly property int listPadding: 8

    function labelOf(n) { return n ? (n.description || n.nickname || n.name || "Unknown") : "No device" }
    function open() { opened = true }
    function close() { opened = false }

    width: parent ? parent.width : 200
    // In overlay mode, height stays at header only; dropdown floats on top
    height: overlayMode ? header.height : header.height + (opened ? dropdownBg.height : 0)
    clip: overlayMode ? false : true
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
            onClicked: { root.opened = !root.opened }
        }
    }

    // List - in overlay mode, floats on top below header; otherwise inline
    Rectangle {
        id: dropdownBg
        y: overlayMode ? -dropdownBg.height : header.height
        width: parent.width
        height: Math.min(list.implicitHeight + listPadding, root.maxDropdownHeight)
        radius: 10; color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: 1
        clip: true
        visible: root.opened
        z: overlayMode ? 100 : 0
        layer.enabled: overlayMode

        Flickable {
            id: flickable
            anchors.fill: parent
            anchors.margins: 4
            contentWidth: parent.width - 8
            contentHeight: list.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: list.height > root.maxDropdownHeight - listPadding

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
                        width: list.width
                        height: root.itemHeight
                        radius: 8
                        property bool isCur: !!root.currentNode && modelData.name === root.currentNode.name
                        color: ma.containsMouse ? "#2a2a2a" : "transparent"
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
                            onClicked: { root.picked(modelData); root.opened = false }
                        }
                    }
                }
            }
        }
    }
}
