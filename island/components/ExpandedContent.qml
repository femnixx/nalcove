// island/components/ExpandedContent.qml - Stub for expanded dashboard content
import qs.components as Theme

import QtQuick 2.15


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
