import QtQuick
import QtQuick.Controls

// Month grid + today card
Item {
    id: root

    function cells() {
        const n = Clock.now
        const first = new Date(n.getFullYear(), n.getMonth(), 1)
        const offset = (first.getDay() + 6) % 7
        const total = new Date(n.getFullYear(), n.getMonth() + 1, 0).getDate()
        const out = []
        for (let i = 0; i < offset; i++) out.push(0)
        for (let d = 1; d <= total; d++) out.push(d)
        return out
    }

    Rectangle {
        x: 0; y: 0
        width: 380; height: root.height
        color: Theme.card
        radius: Theme.cardRadius

        Text {
            x: 20; y: 12
            text: Qt.formatDate(Clock.now, "MMMM yyyy")
            color: Theme.fg
            font.pixelSize: 16
            font.bold: true
        }
        Row {
            x: 20; y: 44
            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: Item {
                    width: 48; height: 16
                    Text { anchors.centerIn: parent; text: modelData; color: Theme.dim; font.pixelSize: 11 }
                }
            }
        }
        Grid {
            x: 20; y: 64
            columns: 7
            Repeater {
                model: root.cells()
                delegate: Item {
                    width: 48; height: 23
                    Rectangle {
                        anchors.centerIn: parent
                        width: 22; height: 22; radius: 11
                        visible: modelData === Clock.now.getDate()
                        color: Theme.accent
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: modelData > 0
                        text: modelData
                        color: Theme.fg
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    Rectangle {
        x: 392; y: 0
        width: 328; height: root.height
        color: Theme.card
        radius: Theme.cardRadius

        Column {
            anchors.centerIn: parent
            spacing: 6
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(Clock.now, "d")
                color: Theme.fg
                font.pixelSize: 56
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(Clock.now, "dddd")
                color: Theme.fg
                font.pixelSize: 15
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Nothing scheduled"
                color: Theme.dim
                font.pixelSize: 12
            }
        }
    }
}
