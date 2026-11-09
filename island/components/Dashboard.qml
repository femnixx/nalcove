import QtQuick

// Expanded island: tab bar + content. Fixed 720x208 content area (island is 760x280).
Item {
    id: root
    property bool active: false
    property int tab: 0
    readonly property var tabs: ["Home", "Music", "Calendar", "Notes", "Controls"]

    Row {
        x: 20; y: 14
        spacing: 6
        Repeater {
            model: root.tabs
            delegate: Rectangle {
                height: 28
                width: label.implicitWidth + 26
                radius: 14
                color: root.tab === index ? Theme.cardHi : "transparent"
                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData
                    color: root.tab === index ? Theme.fg : Theme.dim
                    font.pixelSize: 12
                    font.bold: root.tab === index
                }
                MouseArea { anchors.fill: parent; onClicked: root.tab = index }
            }
        }
    }

    Text {
        id: stamp
        x: 740 - width
        y: 20
        text: Qt.formatDateTime(Clock.now, "ddd d MMM   HH:mm")
        color: Theme.dim
        font.pixelSize: 12
    }

    // Horizontal swipe on touchpad/mouse switches tabs (next on left-swipe, prev on right-swipe)
    DragHandler {
        id: swipeNav
        target: null
        yAxis.enabled: false
        property real lastDx: 0
        onTranslationChanged: lastDx = translation.x
        onActiveChanged: {
            if (active) return
            if (lastDx > 60) {
                root.tab = Math.max(0, root.tab - 1)
            } else if (lastDx < -60) {
                root.tab = Math.min(root.tabs.length - 1, root.tab + 1)
            }
        }
    }

    Item {
        x: 20; y: 54
        width: 720; height: 208

        HomeTab     { anchors.fill: parent; visible: root.tab === 0 }
        MusicTab    { anchors.fill: parent; visible: root.tab === 1 }
        CalendarTab { anchors.fill: parent; visible: root.tab === 2 }
        NotesTab    { anchors.fill: parent; visible: root.tab === 3 }
        ControlsTab { anchors.fill: parent; visible: root.tab === 4 }
    }
}
