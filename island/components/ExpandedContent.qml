// island/components/ExpandedContent.qml - Stub for expanded dashboard content

import QtQuick 2.15
import qs.components 1.0 as Style

Item {
    id: expandedContentRoot

    property alias opacity: contentItem.opacity
    property alias enabled: contentItem.enabled

    Item {
        id: contentItem
        anchors.fill: parent
        opacity: 0
        enabled: false
        color: Style.islandFill
    }

    Component.onCompleted: {
        // Stub - replaced in Phase 6
    }
}
