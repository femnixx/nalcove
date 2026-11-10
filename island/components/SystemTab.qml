import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../services" as Services


Item {
    id: root
    // GPU polling wakes a hybrid NVIDIA GPU and costs battery. Leave off unless you want it.
    property bool showGpu: false

    property real cpu: 0
    property real memUsed: 0
    property real memTotal: 0
    property real temp: -1
    property real power: -1
    property real gpu: -1
    property real gpuTemp: -1
    property real _prevIdle: 0
    property real _prevTotal: 0

    function parse(text) {
        for (const line of text.split("\n")) {
            if (line.startsWith("cpu ")) {
                const f = line.trim().split(/\s+/).slice(1).map(Number)
                const idle = f[3] + (f[4] || 0)
                const total = f.reduce((a, b) => a + b, 0)
                if (_prevTotal > 0 && total > _prevTotal)
                    cpu = 1 - (idle - _prevIdle) / (total - _prevTotal)
                _prevIdle = idle; _prevTotal = total
            } else if (line.startsWith("MEM:")) {
                const p = line.slice(4).trim().split(" ").map(Number)
                memTotal = p[0] / 1048576; memUsed = (p[0] - p[1]) / 1048576   // GiB
            } else if (line.startsWith("TEMP:")) {
                temp = Number(line.slice(5)) / 1000
            } else if (line.startsWith("POWER:")) {
                power = Math.abs(Number(line.slice(6))) / 1000000              // W
            } else if (line.startsWith("GPU:")) {
                const p = line.slice(4).split(",").map(s => Number(s.trim()))
                gpu = p[0]; gpuTemp = p[1]
            }
        }
    }

    Process {
        id: proc
        command: ["sh", Quickshell.shellPath("scripts/sysstat.sh")].concat(root.showGpu ? ["gpu"] : [])
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }
    Timer { interval: 1500; running: root.visible; repeat: true; triggeredOnStart: true
            onTriggered: proc.running = true }

    readonly property string powerState:
        !Services.Battery.ready ? "" : Services.Battery.charging ? "Charging" : Services.Battery.full ? "Full"
        : (UPower.displayDevice.state === UPowerDeviceState.Discharging ? "Discharging" : "")

    readonly property var rows: {
        const r = [
            { label: "CPU", text: Math.round(cpu * 100) + "%", frac: cpu, color: Theme.accent },
            { label: "Memory", text: memUsed.toFixed(1) + " / " + memTotal.toFixed(1) + " GiB",
              frac: memTotal > 0 ? memUsed / memTotal : 0, color: "#bf5af2" }
        ]
        if (temp >= 0) r.push({ label: "CPU Temp", text: Math.round(temp) + " \u00b0C", frac: Math.min(1, temp / 100),
                                color: temp > 80 ? Theme.danger : "#ff9f0a" })
        if (power >= 0) r.push({ label: "Power draw", text: power.toFixed(1) + " W  " + powerState,
                                 frac: Math.min(1, power / 60), color: Theme.success })
        if (gpu >= 0) r.push({ label: "GPU", text: Math.round(gpu) + "%  " + Math.round(gpuTemp) + " \u00b0C",
                               frac: gpu / 100, color: "#64d2ff" })
        return r
    }

    Column {
        anchors.fill: parent; anchors.margins: Theme.s4; spacing: Theme.s3

        Repeater {
            model: root.rows
            delegate: Card {
                Layout.fillWidth: true
                hoverEnabled: false

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.s4
                    spacing: Theme.s2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.s2

                        Text {
                            text: modelData.label
                            color: Theme.dim
                            font.pixelSize: Theme.tSmall
                            font.family: Theme.fontFamily
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: modelData.text
                            color: Theme.fg
                            font.pixelSize: Theme.tSmall
                            font.bold: true
                            font.family: Theme.fontFamily
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Theme.track

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, modelData.frac)); height: parent.height
                            radius: 3; color: modelData.color
                            Behavior on width { NumberAnimation { duration: 400 } }
                        }
                    }
                }
            }
        }
    }
}