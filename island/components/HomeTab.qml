import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"


Item {
    id: root
    clip: true
    signal navigate(string page)

    readonly property real gap: Theme.s3
    readonly property real avail: width - 3 * gap

    // Rebuild the week only when the DAY changes, not on every clock tick.
    readonly property int today: Clock.now.getDate()
    readonly property var week: { today; return buildWeek() }

    function buildWeek() {
        const n = new Date()
        const monday = new Date(n.getFullYear(), n.getMonth(), n.getDate() - ((n.getDay() + 6) % 7))
        const out = []
        for (let i = 0; i < 7; i++) {
            const d = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i)
            out.push({
                letter: Qt.formatDate(d, "ddd").charAt(0),
                num: d.getDate(),
                today: d.getDate() === n.getDate() && d.getMonth() === n.getMonth()
            })
        }
        return out
    }

    Row {
        anchors.fill: parent
        spacing: root.gap

        // ---- music ----
        MusicCard { width: root.avail * 0.31; height: parent.height }

        // ---- week strip + weather ----
        Column {
            width: root.avail * 0.285
            height: parent.height
            spacing: root.gap

            Card {
                id: weekCard
                width: parent.width
                height: (parent.height - root.gap) / 2
                hoverEnabled: false

                Text {
                    x: Theme.s4; y: Theme.s3
                    text: Qt.formatDate(Clock.now, "MMMM")
                    color: Theme.fg
                    font.pixelSize: 17
                    font.bold: true
                    font.family: Theme.fontFamily
                }
                Row {
                    x: Theme.s4
                    y: parent.height - height - Theme.s3
                    Repeater {
                        model: root.week
                        delegate: Item {
                            width: (weekCard.width - Theme.s4 * 2) / 7
                            height: 44
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.letter
                                color: Theme.dim
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 16
                                width: 24; height: 24; radius: 12
                                color: modelData.today ? Theme.accent : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.num
                                    color: Theme.fg
                                    font.pixelSize: 11
                                    font.family: Theme.fontFamily
                                    font.bold: modelData.today
                                }
                            }
                        }
                    }
                }
            }

            WeatherCard {
                width: parent.width
                height: (parent.height - root.gap) / 2
            }
        }

        // ---- clock ----
        Card {
            width: root.avail * 0.17
            height: parent.height
            hoverEnabled: false

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(Clock.now, "HH:mm")
                    color: Theme.fg
                    font.pixelSize: 28
                    font.bold: true
                    font.family: Theme.fontFamily
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "dddd")
                    color: Theme.fg
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "d MMMM")
                    color: Theme.dim
                    font.pixelSize: 11
                    font.family: Theme.fontFamily
                }
            }
        }

        // ---- per-app volume mixer + volume + brightness ----
        Column {
            width: root.avail * 0.235
            height: parent.height
            spacing: root.gap

            AppMixer {
                width: parent.width
                height: parent.height * 0.45
            }

            // Volume + Brightness in a ColumnLayout so dropdown pushes brightness down
            ColumnLayout {
                width: parent.width
                height: parent.height * 0.55
                spacing: Theme.s3

                VolumeCard {
                    Layout.fillWidth: true
                    onOutputClicked: root.navigate("volume")
                }

                BrightnessCard {
                    Layout.fillWidth: true
                }
            }
        }
    }
}