import QtQuick
import qs.components as Theme
import Quickshell.Io


Item {
    id: root
    property string weatherDesc: "Loading..."
    property string temp: "--°"
    property string iconName: "cloud"
    property string city: "Unknown"
    property bool loading: true

    Process {
        id: weatherFetch
        command: ["bash", "-c", "curl -s 'wttr.in/?format=%l|%c|%t|%C' 2>/dev/null || echo 'Error|☁️|--°|Unknown'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length >= 4) {
                    root.city = parts[0]
                    root.iconName = weatherIconMap(parts[1])
                    root.temp = parts[2]
                    root.weatherDesc = parts[3]
                    root.loading = false
                }
            }
        }
        Component.onCompleted: { weatherFetch.running = true }
    }

    Timer {
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        onTriggered: { weatherFetch.running = true }
    }

    function weatherIconMap(desc) {
        const d = desc.toLowerCase()
        if (d.includes("sun") || d.includes("clear")) return "sun"
        if (d.includes("cloud") || d.includes("overcast")) return "cloud"
        if (d.includes("rain") || d.includes("drizzle") || d.includes("shower")) return "cloud-rain"
        if (d.includes("snow") || d.includes("sleet") || d.includes("hail")) return "cloud-snow"
        if (d.includes("thunder") || d.includes("storm")) return "cloud-lightning"
        if (d.includes("mist") || d.includes("fog") || d.includes("haze")) return "cloud-fog"
        return "cloud"
    }

    Card {
        anchors.fill: parent
        hoverEnabled: false

        Column {
            anchors.fill: parent
            anchors.margins: Theme.s3
            spacing: Theme.s1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.loading ? "Loading..." : root.city
                color: Theme.dim
                font.pixelSize: Theme.tCaption
                elide: Text.ElideRight
            }

            Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: root.iconName
                size: 36
                color: Theme.fg
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.temp
                color: Theme.fg
                font.pixelSize: 24
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.weatherDesc
                color: Theme.dim
                font.pixelSize: Theme.tCaption
                elide: Text.ElideRight
            }
        }
    }
}