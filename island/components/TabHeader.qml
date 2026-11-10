import QtQuick
import QtQuick.Layouts


Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: Style.rowH

    property string title: ""
    property bool showTrailing: false
    property var trailingItem: null

    RowLayout {
        anchors.fill: parent
        spacing: Style.s2

        Text {
            text: root.title
            font.pixelSize: Style.tTitle
            font.bold: true
            color: Style.fg
            font.family: Style.fontFamily
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        Loader {
            sourceComponent: root.trailingItem
            Layout.alignment: Qt.AlignVCenter
            active: root.showTrailing && root.trailingItem !== null
        }
    }
}