import QtQuick
import "../services"
import "../components"

// Alcove-style Home: music | week + weather | clock | AppMixer | volume + brightness
Item {
    id: root
    clip: true
    signal navigate(string page)

    readonly property real gap: 12
    readonly property real avail: width - 3 * gap

    // Rebuild the week only when the DAY changes, not on every clock tick.
    readonly property int today: Clock.now.getDate()
    readonly property var week: { today; return buildWeek() }

    function buildWeek() {
        const n = new Date()                       // not Clock.now, so no per-tick dependency
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

            Rectangle {
                id: weekCard
                width: parent.width
                height: (parent.height - root.gap) / 2
                color: Style.card
                radius: Style.cardRadius
                clip: true

                Text {
                    x: 14; y: 12
                    text: Qt.formatDate(Clock.now, "MMMM")
                    color: Style.fg
                    font.pixelSize: 17
                    font.bold: true
                }
                Row {
                    x: 14
                    y: parent.height - height - 12
                    Repeater {
                        model: root.week
                        delegate: Item {
                            width: (weekCard.width - 28) / 7
                            height: 44
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.letter
                                color: Style.dim
                                font.pixelSize: 10
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 16
                                width: 24; height: 24; radius: 12
                                color: modelData.today ? Style.accent : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.num
                                    color: Style.fg
                                    font.pixelSize: 11
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
        Rectangle {
            width: root.avail * 0.17
            height: parent.height
            color: Style.card
            radius: Style.cardRadius
            clip: true

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(Clock.now, "HH:mm")
                    color: Style.fg
                    font.pixelSize: 28
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "dddd")
                    color: Style.fg
                    font.pixelSize: 12
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "d MMMM")
                    color: Style.dim
                    font.pixelSize: 11
                }
            }
        }

        // ---- per-app volume mixer ----
        AppMixer {
            width: root.avail * 0.235
            height: parent.height * 0.45
        }

        // ---- volume + brightness ----
        VolumeCard {
            id: volumeCard
            width: root.avail * 0.235
            onOutputClicked: root.navigate("volume")
        }
    }
}