import QtQuick


Item {
    id: root
    property real ui: 1
    width: s(4)
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    visible: root.flickable && root.flickable.contentHeight > root.flickable.height && root.flickable.visible

    function s(px) { return Math.round(px * ui) }

    property var flickable: null
    property real fadeDelay: 800

    Rectangle {
        id: handle
        width: parent.width
        radius: s(2)
        color: Style.dim
        opacity: root._visible ? 0.6 : 0
        y: root._visible ? (root.flickable.contentY / root.flickable.contentHeight) * (root.height - height) : 0
        height: Math.max(s(30), (root.flickable.height / root.flickable.contentHeight) * root.height)

        Behavior on y { NumberAnimation { duration: 100 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    property bool _visible: false

    Timer {
        id: hideTimer
        interval: root.fadeDelay
        onTriggered: root._visible = false
    }

    Connections {
        target: root.flickable
        function onContentYChanged() {
            if (root.flickable.contentHeight > root.flickable.height) {
                root._visible = true
                hideTimer.restart()
            }
        }
        function onContentHeightChanged() {
            root._visible = root.flickable.contentHeight > root.flickable.height
            if (!root._visible) hideTimer.stop()
        }
    }
}
