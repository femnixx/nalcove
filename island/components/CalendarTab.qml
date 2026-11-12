import QtQuick
import QtQuick.Controls
import "../services"

// Month grid + today card
Item {
    property real ui: 1
    id: root
    clip: true

    function s(px) { return Math.round(px * ui) }

    // Rebuild only when the day changes
    readonly property int today: Clock.now.getDate()
    readonly property var cellList: { today; return buildCells() }

    function buildCells() {
        const n = new Date()
        const first = new Date(n.getFullYear(), n.getMonth(), 1)
        const offset = (first.getDay() + 6) % 7
        const total = new Date(n.getFullYear(), n.getMonth() + 1, 0).getDate()
        const out = []
        for (let i = 0; i < offset; i++) out.push(0)
        for (let d = 1; d <= total; d++) out.push(d)
        return out
    }

    readonly property real gap: s(12)
    readonly property real leftW: (width - gap) * 0.53

    Rectangle {
        id: monthCard
        x: 0; y: 0
        width: root.leftW; height: root.height
        color: Style.card
        radius: Style.cardRadius

        readonly property real cell: (width - s(40)) / 7

        Text {
            x: s(20); y: s(12)
            text: Qt.formatDate(Clock.now, "MMMM yyyy")
            color: Style.fg
            font.pixelSize: 16 * ui
            font.bold: true
        }
        Row {
            x: s(20); y: s(44)
            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: Item {
                    width: monthCard.cell; height: s(16)
                    Text { anchors.centerIn: parent; text: modelData; color: Style.dim; font.pixelSize: 11 * ui }
                }
            }
        }
        Grid {
            x: s(20); y: s(64)
            columns: 7
            Repeater {
                model: root.cellList
                delegate: Item {
                    width: monthCard.cell
                    height: Math.min(s(26), (monthCard.height - s(72)) / 6)
                    Rectangle {
                        anchors.centerIn: parent
                        width: s(22); height: s(22); radius: s(11)
                        visible: modelData === root.today
                        color: Style.accent
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: modelData > 0
                        text: modelData
                        color: Style.fg
                        font.pixelSize: 12 * ui
                    }
                }
            }
        }
    }

    Rectangle {
        x: root.leftW + root.gap; y: 0
        width: root.width - x; height: root.height
        color: Style.card
        radius: Style.cardRadius

        Column {
            anchors.centerIn: parent
            spacing: s(6)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(Clock.now, "d")
                color: Style.fg
                font.pixelSize: 56 * ui
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(Clock.now, "dddd")
                color: Style.fg
                font.pixelSize: 15 * ui
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Nothing scheduled"
                color: Style.dim
                font.pixelSize: 12 * ui
            }
        }
    }
}
