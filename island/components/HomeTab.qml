import QtQuick
import QtQuick.Layouts
import "../services"
import "../components"

// Alcove-style Home, responsive.
//
//   wide (width >= s(640) and room for 2 rows): explicit 4 x 2 placement
//
//            col0     col1      col2     col3
//     row0   music    week      clock    volume
//     row1   music    weather   clock    brightness      (music + clock span 2 rows)
//
//   medium (>= s(400)): 2 columns, auto placed
//   narrow (<  s(400)): 1 column, auto placed
//
// In medium/narrow modes only as many cards are shown as fit the height, lowest
// priority hidden first (weather, then brightness, ...). Nothing is clipped off the
// bottom any more. All breakpoints are in scaled pixels (s()), like everything else.
Item {
    id: root
    property real ui: 1
    signal navigate(string page)

    function s(px) { return Math.round(px * ui) }

    readonly property real gap: s(12)
    readonly property real minCardH: s(100)

    // how many card rows fit in the height we were given
    readonly property int fitRows: Math.max(1, Math.floor((height + gap) / (minCardH + gap)))

    readonly property bool wide: width >= s(640) && fitRows >= 2
    readonly property int columns: wide ? 4 : (width >= s(400) ? 2 : 1)

    // number of cards shown, in priority order:
    // 1 music, 2 week, 3 clock, 4 volume, 5 brightness, 6 weather
    readonly property int capacity: wide ? 6 : columns * fitRows

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

    GridLayout {
        id: grid
        anchors.fill: parent
        columns: root.columns
        columnSpacing: root.gap
        rowSpacing: root.gap

        // ---- 1. music ----
        MusicCard {
            ui: root.ui
            visible: root.capacity >= 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: s(150)
            Layout.minimumHeight: root.minCardH
            Layout.row: root.wide ? 0 : -1          // -1 = auto placement
            Layout.column: root.wide ? 0 : -1
            Layout.rowSpan: root.wide ? 2 : 1
        }

        // ---- 2. week strip ----
        Rectangle {
            id: weekCard
            visible: root.capacity >= 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: s(140)
            Layout.minimumHeight: root.minCardH
            Layout.row: root.wide ? 0 : -1
            Layout.column: root.wide ? 1 : -1
            color: Style.card
            radius: s(Style.cardRadius)
            clip: true

            Text {
                x: s(14); y: s(12)
                text: Qt.formatDate(Clock.now, "MMMM")
                color: Style.fg
                font.pixelSize: 17 * ui
                font.bold: true
            }
            Row {
                x: s(14)
                y: parent.height - height - s(12)
                Repeater {
                    model: root.week
                    delegate: Item {
                        width: (weekCard.width - s(28)) / 7
                        height: s(44)
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.letter
                            color: Style.dim
                            font.pixelSize: 10 * ui
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: s(16)
                            width: s(24); height: s(24); radius: s(12)
                            color: modelData.today ? Style.accent : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData.num
                                color: Style.fg
                                font.pixelSize: 11 * ui
                                font.bold: modelData.today
                            }
                        }
                    }
                }
            }
        }

        // ---- 6. weather (lowest priority; sits under the week strip when wide) ----
        WeatherCard {
            ui: root.ui
            visible: root.capacity >= 6
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: s(140)
            Layout.minimumHeight: root.minCardH
            Layout.row: root.wide ? 1 : -1
            Layout.column: root.wide ? 1 : -1
        }

        // ---- 3. clock ----
        Rectangle {
            visible: root.capacity >= 3
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: s(140)
            Layout.minimumHeight: root.minCardH
            Layout.row: root.wide ? 0 : -1
            Layout.column: root.wide ? 2 : -1
            Layout.rowSpan: root.wide ? 2 : 1
            color: Style.card
            radius: s(Style.cardRadius)
            clip: true

            Column {
                anchors.centerIn: parent
                spacing: s(4)
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(Clock.now, "HH:mm")
                    color: Style.fg
                    font.pixelSize: 28 * ui
                    font.bold: true
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "dddd")
                    color: Style.fg
                    font.pixelSize: 12 * ui
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Clock.now, "d MMMM")
                    color: Style.dim
                    font.pixelSize: 11 * ui
                }
            }
        }

        // ---- 4. output volume ----
        VolumeCard {
            ui: root.ui
            visible: root.capacity >= 4
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: s(140)
            Layout.minimumHeight: root.minCardH
            Layout.row: root.wide ? 0 : -1
            Layout.column: root.wide ? 3 : -1
        }

        // ---- 5. brightness ----
        BrightnessCard {
            ui: root.ui
            visible: root.capacity >= 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: s(140)
            Layout.minimumHeight: root.minCardH
            Layout.row: root.wide ? 1 : -1
            Layout.column: root.wide ? 3 : -1
        }
    }
}
