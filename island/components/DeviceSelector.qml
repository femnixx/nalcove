import QtQuick
import QtQuick.Layouts


Item {
    id: root
    Layout.fillWidth: true

    property var model: []
    property var currentNode: null
    property bool opened: false
    property bool accordionGroup: false  // if true, opening this closes siblings in same group
    signal picked(var node)

    function labelOf(n) { return n ? (n.description || n.nickname || n.name || "No device") : "No device" }
    function open() { 
        opened = true
        if (accordionGroup && parent) {
            var siblings = parent.children
            for (var i = 0; i < siblings.length; i++) {
                if (siblings[i] !== root && siblings[i].accordionGroup) {
                    siblings[i].opened = false
                }
            }
        }
    }
    function close() { opened = false }
    function toggle() { opened = !opened }

    // Layout sizing: minimum = header only, preferred = header + list (when open)
    readonly property int headerHeight: Theme.controlH
    readonly property int listItemHeight: 36
    readonly property int listMaxHeight: 200
    readonly property int naturalListHeight: Math.min(listMaxHeight, (model ? model.length : 0) * listItemHeight + 8)
    Layout.minimumHeight: headerHeight
    Layout.preferredHeight: opened ? (headerHeight + naturalListHeight + 8) : headerHeight

    // Header
    Rectangle {
        id: header
        width: parent.width
        height: headerHeight
        radius: Theme.rMd
        color: Theme.card
        border.color: Theme.cardBorder
        border.width: 1

        Text {
            anchors.fill: parent
            anchors.leftMargin: Theme.s4
            anchors.rightMargin: Theme.s4 + Theme.iconMd
            text: root.labelOf(root.currentNode)
            color: Theme.fg
            font.pixelSize: Theme.tBody
            font.family: Theme.fontFamily
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: Theme.s3
            anchors.verticalCenter: parent.verticalCenter
            text: root.opened ? "▴" : "▾"
            color: Theme.dim
            font.pixelSize: Theme.iconSm
            Behavior on rotation { NumberAnimation { duration: Theme.dFast; easing.type: Theme.easingOutCubic } }
            rotation: root.opened ? 180 : 0
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.toggle()
        }
    }

    // List - uses anchors so layout shrink reaches it
    Rectangle {
        id: listContainer
        anchors.top: header.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        radius: Theme.rMd
        color: Theme.card
        border.color: Theme.cardBorder
        border.width: 1
        visible: root.opened
        clip: true

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            spacing: 2
            model: root.model
            interactive: contentHeight > height

            delegate: Rectangle {
                width: ListView.view.width
                height: listItemHeight
                radius: Theme.rSm

                property bool isCur: !!root.currentNode && modelData.name === root.currentNode.name
                property bool hovered: ma.containsMouse

                color: hovered ? Theme.cardHi : "transparent"

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.s3
                    anchors.rightMargin: Theme.s3
                    text: root.labelOf(modelData)
                    color: isCur ? Theme.accent : Theme.fg
                    font.pixelSize: Theme.tBody
                    font.family: Theme.fontFamily
                    font.bold: isCur
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