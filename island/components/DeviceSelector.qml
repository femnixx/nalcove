import QtQuick

Item {
    id: root
    property real ui: 1
    property var model: []
    property var currentNode: null
    property bool opened: false
    property real maxDropdownHeight: root.itemHeight * 4 + root.listSpacing * 3 + root.listPadding
    property bool overlayMode: false
    signal picked(var node)

    function s(px) { return Math.round(px * ui) }

    readonly property int itemHeight: s(30)
    readonly property int listSpacing: s(2)
    readonly property int listPadding: s(8)

    function labelOf(n) { return n ? (n.description || n.nickname || n.name || "Unknown") : "No device" }
    function open() { opened = true }
    function close() { opened = false }

    width: parent ? parent.width : s(200)
    // In overlay mode, height stays at header only; dropdown floats on top
    height: overlayMode ? header.height : header.height + (opened ? dropdownBg.height : 0)
    clip: overlayMode ? false : true
    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    // Header
    Rectangle {
        id: header
        width: parent.width; height: s(32); radius: s(10); color: "#1a1a1a"
        Text {
            anchors.fill: parent; anchors.leftMargin: s(10); anchors.rightMargin: s(26)
            text: root.labelOf(root.currentNode)
            color: "#ffffff"; font.pixelSize: 12 * ui
            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: s(10)
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
        radius: s(10); color: "#1a1a1a"; border.color: "#2a2a2a"; border.width: s(1)
        clip: true
        visible: root.opened
        z: overlayMode ? 100 : 0
        layer.enabled: overlayMode

        Flickable {
            id: flickable
            anchors.fill: parent
            anchors.margins: s(4)
            contentWidth: parent.width - s(8)
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
                    text: "No devices found"; color: "#9a9aa0"; font.pixelSize: 12 * ui
                    height: s(30); verticalAlignment: Text.AlignVCenter; leftPadding: s(10)
                }

                Repeater {
                    model: root.model
                    delegate: Rectangle {
                        width: list.width
                        height: root.itemHeight
                        radius: s(8)
                        property bool isCur: !!root.currentNode && modelData.name === root.currentNode.name
                        color: ma.containsMouse ? "#2a2a2a" : "transparent"
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: s(10)
                            anchors.rightMargin: s(10)
                            text: root.labelOf(modelData)
                            color: parent.isCur ? "#3b8bff" : "#ffffff"
                            font.pixelSize: 12 * ui
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
