import QtQuick
import qs.components 1.0
import QtQuick.Controls
import QtQuick.Layouts


// Month grid + today card
Item {
    id: root
    clip: true
    Layout.fillWidth: true
    Layout.fillHeight: true

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

    RowLayout {
        anchors.fill: parent
        spacing: Theme.s3

        // Month calendar
        Card {
            id: monthCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 300
            hoverEnabled: false

            Column {
                anchors.fill: parent
                anchors.margins: Theme.s4
                spacing: Theme.s3

                Text {
                    text: Qt.formatDate(Clock.now, "MMMM yyyy")
                    color: Theme.fg
                    font.pixelSize: Theme.tTitle
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                readonly property real cell: (parent.width - Theme.s4 * 2) / 7

                Row {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: ["M", "T", "W", "T", "F", "S", "S"]
                        delegate: Item {
                            Layout.fillWidth: true
                            height: 16
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: Theme.dim
                                font.pixelSize: Theme.tCaption
                                font.family: Theme.fontFamily
                            }
                        }
                    }
                }

                Grid {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    spacing: 0

                    Repeater {
                        model: root.cellList
                        delegate: Item {
                            width: monthCard.cell
                            height: Math.min(Theme.controlH, (parent.height - 20) / 6)

                            Rectangle {
                                anchors.centerIn: parent
                                width: 28; height: 28; radius: 14
                                visible: modelData === root.today
                                color: Theme.accent
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: modelData > 0
                                text: modelData
                                color: modelData === root.today ? "#ffffff" : Theme.fg
                                font.pixelSize: Theme.tSmall
                                font.family: Theme.fontFamily
                                font.bold: modelData === root.today
                            }
                        }
                    }
                }
            }
        }

        // Today detail
        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            hoverEnabled: false

            Column {
                anchors.centerIn: parent
                spacing: Theme.s2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "d")
                    color: Theme.fg
                    font.pixelSize: 56
                    font.bold: true
                    font.family: Theme.fontFamily
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "dddd")
                    color: Theme.fg
                    font.pixelSize: Theme.tBody
                    font.family: Theme.fontFamily
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Nothing scheduled"
                    color: Theme.dim
                    font.pixelSize: Theme.tSmall
                    font.family: Theme.fontFamily
                }
            }
        }
    }
}