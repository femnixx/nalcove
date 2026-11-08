// island/components/ExpandedContent.qml - Stub for expanded dashboard content

import QtQuick 2.15
import Island 1.0 as Theme

Item {
    id: expandedContentRoot

    property alias opacity: contentItem.opacity
    property alias enabled: contentItem.enabled

    Item {
        id: contentItem
        anchors.fill: parent
        opacity: 0
        enabled: false
        color: Theme.islandFill
    }

    Component.onCompleted: {
        // Stub - replaced in Phase 6
    }
}
