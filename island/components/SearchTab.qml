import QtQuick
import Quickshell
import "../services" as Services

Item {
    id: tab
    property string query: ""
    property int sel: 0
    signal launched()                       // Dashboard/Island should close the island on this

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

    Rectangle {
        id: box
        width: parent.width; height: 40; radius: 12; color: "#1a1a1a"
        border.width: 1; border.color: input.activeFocus ? "#3b8bff" : "#2a2a2e"

        Icon { x: 12; anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 16; color: "#9a9aa0" }
        TextInput {
            id: input
            anchors.left: parent.left; anchors.leftMargin: 38
            anchors.right: parent.right; anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"; font.pixelSize: 14; clip: true; selectByMouse: true
            text: tab.query
            onTextEdited: tab.query = text

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down)      { tab.sel = Math.min(tab.sel + 1, tab.results.length - 1); event.accepted = true }
                else if (event.key === Qt.Key_Up)   { tab.sel = Math.max(tab.sel - 1, 0); event.accepted = true }
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { tab.activate(tab.sel); event.accepted = true }
                else if (event.key === Qt.Key_Escape && tab.query !== "") { tab.query = ""; input.text = ""; event.accepted = true }
                // Esc with an empty field falls through to the island, which closes it
            }
            Text { visible: input.text === ""; text: "Search applications…"; color: "#66ffffff"; font.pixelSize: 14 }
        }
    }

    ListView {
        anchors.top: box.bottom; anchors.topMargin: 8
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        clip: true; spacing: 2; interactive: false
        model: tab.results

        delegate: Rectangle {
            required property var modelData
            required property int index
            width: ListView.view.width; height: 42; radius: 10
            color: index === tab.sel ? "#2a2a2e" : (ma.containsMouse ? "#1f1f22" : "transparent")

            Image {
                x: 10; anchors.verticalCenter: parent.verticalCenter
                width: 26; height: 26
                sourceSize: Qt.size(52, 52); asynchronous: true
                source: Quickshell.iconPath(modelData.icon, "application-x-executable")
            }
            Column {
                x: 46; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 60; spacing: 1
                Text { width: parent.width; text: modelData.name; color: "#ffffff"; font.pixelSize: 13; elide: Text.ElideRight }
                Text { width: parent.width; text: modelData.comment || modelData.genericName || ""
                       color: "#9a9aa0"; font.pixelSize: 10; elide: Text.ElideRight; visible: text !== "" }
            }
            MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true
                        onEntered: tab.sel = index; onClicked: tab.activate(index) }
        }
    }
}