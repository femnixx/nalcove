import QtQuick
import "../services" as Services

Item {
    id: panel

    Text {
        anchors.centerIn: parent
        width: parent.width - 20
        visible: Services.Lyrics.status !== "synced" && Services.Lyrics.status !== "plain"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        color: "#9a9aa0"; font.pixelSize: 13
        text: ({
            idle: "Nothing playing",
            loading: "Searching lyrics\u2026",
            none: "No lyrics found for this track",
            error: "Couldn't reach the lyrics server.\nTap to retry"
        })[Services.Lyrics.status] || ""
        MouseArea {
            anchors.fill: parent
            enabled: Services.Lyrics.status === "error"
            onClicked: Services.Lyrics.retry()
        }
    }

    ListView {
        id: lv
        anchors.fill: parent
        visible: Services.Lyrics.status === "synced"
        clip: true
        interactive: false
        spacing: 10
        model: Services.Lyrics.lines
        currentIndex: Math.max(0, Services.Lyrics.activeIndex)
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: height / 2 - 24
        preferredHighlightEnd: height / 2 + 24
        highlightMoveDuration: 300

        delegate: Text {
            required property var modelData
            required property int index
            readonly property bool cur: index === Services.Lyrics.activeIndex
            width: lv.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: modelData.text !== "" ? modelData.text : "\u266a"
            color: cur ? "#ffffff" : "#66ffffff"
            font.pixelSize: cur ? 16 : 13
            font.bold: cur
            Behavior on color { ColorAnimation { duration: 200 } }
            MouseArea { anchors.fill: parent; onClicked: Services.Media.seek(modelData.t) }
        }
    }

    Flickable {
        anchors.fill: parent
        visible: Services.Lyrics.status === "plain"
        clip: true
        contentWidth: width
        contentHeight: plainText.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        Text {
            id: plainText
            width: panel.width
            text: Services.Lyrics.plain
            color: "#cfcfd4"; font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}