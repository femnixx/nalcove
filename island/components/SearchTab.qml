import QtQuick
import qs.components 1.0
import QtQuick.Controls
import Quickshell
import "../services" as Services


Item {
    id: tab
    property string query: ""
    property int sel: 0
    signal launched()

    readonly property var results: Services.Apps.search(query, 7)

    onQueryChanged: sel = 0
    Component.onCompleted: input.forceActiveFocus()

    function activate(i) {
        var e = results[i]
        if (!e) return
        Services.Apps.launch(e)
        query = ""
        tab.launched()
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.s4
        spacing: Theme.s3

        Card {
            Layout.fillWidth: true
            hoverEnabled: false

            Row {
                anchors.fill: parent
                anchors.margins: Theme.s3
                spacing: Theme.s3

                Icon {
                    name: "search"
                    size: Theme.iconMd
                    color: input.activeFocus ? Theme.accent : Theme.dim
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: Theme.dFast } }
                }

                TextInput {
                    id: input
                    Layout.fillWidth: true
                    color: Theme.fg
                    font.pixelSize: Theme.tBody
                    font.family: Theme.fontFamily
                    clip: true
                    selectByMouse: true
                    text: tab.query
                    onTextEdited: tab.query = text

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down)      { tab.sel = Math.min(tab.sel + 1, tab.results.length - 1); event.accepted = true }
                        else if (event.key === Qt.Key_Up)   { tab.sel = Math.max(tab.sel - 1, 0); event.accepted = true }
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { tab.activate(tab.sel); event.accepted = true }
                        else if (event.key === Qt.Key_Escape && tab.query !== "") { tab.query = ""; input.text = ""; event.accepted = true }
                    }
                }
            }
        }

        Divider {}

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.s1
            interactive: false
            model: tab.results

            delegate: Card {
                width: ListView.view.width
                hoverEnabled: true
                implicitHeight: Theme.controlH

                required property var modelData
                required property int index

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.s3
                    spacing: Theme.s3

                    Image {
                        width: 26; height: 26
                        sourceSize: Qt.size(52, 52)
                        asynchronous: true
                        source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            width: parent.width
                            text: modelData.name
                            color: Theme.fg
                            font.pixelSize: Theme.tBody
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: modelData.comment || modelData.genericName || ""
                            color: Theme.dim
                            font.pixelSize: Theme.tCaption
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                            visible: text !== ""
                        }
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: tab.sel = index
                    onClicked: tab.activate(index)
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: tab.results.length === 0
            icon: "search"
            text: tab.query !== "" ? "No applications found" : "Start typing to search\u2026"
        }
    }
}