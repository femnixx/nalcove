import QtQuick


Rectangle {
    id: root
    property real ui: 1
    Layout.fillWidth: true
    height: s(1)
    color: Style.cardBorder
    visible: root.show

    function s(px) { return Math.round(px * ui) }

    property bool show: true
}
