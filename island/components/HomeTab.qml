import QtQuick
import "../services"

// Alcove-style Home: music card | week strip | clock
Item {
    id: root

    function weekDays() {
        const n = Clock.now
        const monday = new Date(n.getFullYear(), n.getMonth(), n.getDate() - ((n.getDay() + 6) % 7))
        const out = []
        for (let i = 0; i < 7; i++) {
            const d = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i)
            out.push({ letter: Qt.formatDate(d, "ddd").charAt(0), num: d.getDate(), today: d.getDate() === n.getDate() && d.getMonth() === n.getMonth() })
        }
        return out
    }

    MusicCard { x: 0; y: 0; width: 270; height: root.height }

    // Week strip card
    Rectangle {
        x: 282; y: 0
        width: 270; height: root.height
        color: Theme.card
        radius: Theme.cardRadius

        Text {
            x: 18; y: 14
            text: Qt.formatDate(Clock.now, "MMMM")
            color: Theme.fg
            font.pixelSize: 20
            font.bold: true
        }

        Row {
            x: 18; y: 60
            spacing: 4
            Repeater {
                model: root.weekDays()
                delegate: Item {
                    width: 30; height: 56
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 0
                        text: modelData.letter
                        color: Theme.dim
                        font.pixelSize: 11
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 20
                        width: 30; height: 30; radius: 15
                        color: modelData.today ? Theme.accent : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.num
                            color: Theme.fg
                            font.pixelSize: 13
                            font.bold: modelData.today
                        }
                    }
                }
            }
        }

        Rectangle { x: 18; y: 136; width: parent.width - 36; height: 1; color: Theme.track }

        Text {
            x: 18; y: 150
            width: parent.width - 36
            horizontalAlignment: Text.AlignHCenter
            text: "Nothing for today"
            color: Theme.dim
            font.pixelSize: 12
        }
    }

    // Clock card
    Rectangle {
        x: 564; y: 0
        width: 156; height: root.height
        color: Theme.card
        radius: Theme.cardRadius

        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(Clock.now, "HH:mm")
                color: Theme.fg
                font.pixelSize: 34
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(Clock.now, "dddd")
                color: Theme.fg
                font.pixelSize: 13
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(Clock.now, "d MMMM")
                color: Theme.dim
                font.pixelSize: 12
            }
        }
    }
}
