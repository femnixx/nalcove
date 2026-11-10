import QtQuick
import qs.components 1.0
import QtQuick.Layouts


Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: Theme.rowH

    property string title: ""
    property bool showTrailing: false
    property var trailingItem: null

    RowLayout {
        anchors.fill: parent
        spacing: Theme.s2

        Text {
            text: root.title
            font.pixelSize: Theme.tTitle
            font.bold: true
            color: Theme.fg
            font.family: Theme.fontFamily
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