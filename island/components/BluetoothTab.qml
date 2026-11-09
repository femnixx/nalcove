import QtQuick
import Quickshell.Io

Rectangle {
    id: root
    color: Theme.card
    radius: Theme.cardRadius

    property var devices: []
    property bool powered: false

    function parseDevices(output) {
        var lines = output.trim().split("\n")
        var result = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.startsWith("Device ")) {
                var parts = line.split(" ")
                var mac = parts[1]
                var name = parts.slice(2).join(" ")
                var connected = false
                var paired = false
                for (var j = i + 1; j < lines.length && !lines[j].startsWith("Device "); j++) {
                    if (lines[j].includes("Connected: yes")) connected = true
                    if (lines[j].includes("Paired: yes")) paired = true
                }
                result.push({ address: mac, name: name, connected: connected, paired: paired, icon: "bluetooth" })
            }
        }
        return result
    }

    Process {
        id: btList
        command: ["bluetoothctl", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.devices = parseDevices(text)
            }
        }
    }

    Process {
        id: btPower
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.powered = text.includes("Powered: yes")
            }
        }
    }

    Process {
        id: btPowerCmd
    }

    Process {
        id: btConnectCmd
        property string address: ""
        property string cmd: ""
        command: ["bluetoothctl", btConnectCmd.cmd, btConnectCmd.address]
    }

    Timer {
        id: refreshTimer
        interval: 1000
        onTriggered: refresh()
    }

    Component.onCompleted: {
        btList.running = true
        btPower.running = true
    }

    function refresh() {
        btList.running = true
        btPower.running = true
    }

    function onCmdFinished() {
        refresh()
    }

    Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Text {
            text: "Bluetooth"
            color: Theme.fg
            font.pixelSize: 20
            font.bold: true
        }

        Row {
            spacing: 12
            Text {
                text: root.powered ? "On" : "Off"
                color: root.powered ? Theme.good : Theme.dim
                font.pixelSize: 14
                font.bold: true
            }
            Rectangle {
                width: 50; height: 28; radius: 14
                color: root.powered ? Theme.accent : Theme.cardHi
                border.color: Theme.border; border.width: 1
                Rectangle {
                    x: root.powered ? width - 24 : 2
                    y: 2
                    width: 24; height: 24; radius: 12
                    color: "white"
                    Behavior on x { SpringAnimation { spring: 3; damping: 0.5 } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        btPowerCmd.command = ["bluetoothctl", root.powered ? "power off" : "power on"]
                        btPowerCmd.running = true
                        refreshTimer.restart()
                    }
                }
            }
        }

        ListView {
            width: parent.width
            height: parent.height - 120
            model: root.devices
            spacing: 8
            delegate: Rectangle {
                width: parent.width
                height: 56
                color: Theme.cardHi
                radius: 10
                Row {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    Icon {
                        name: modelData.icon || "bluetooth"
                        size: 24
                        color: Theme.fg
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            text: modelData.name || "Unknown"
                            color: Theme.fg
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Text {
                            text: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                            color: modelData.connected ? Theme.good : Theme.dim
                            font.pixelSize: 12
                        }
                    }
                    Item { width: 40 }
                    Rectangle {
                        visible: !modelData.connected
                        width: 70; height: 30; radius: 15
                        color: modelData.paired ? Theme.accent : Theme.cardHi
                        border.color: Theme.border; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData.paired ? "Connect" : "Pair"
                            color: Theme.fg
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                btConnectCmd.address = modelData.address
                                btConnectCmd.cmd = modelData.paired ? "connect" : "pair"
                                btConnectCmd.running = true
                                refreshTimer.restart()
                            }
                        }
                    }
                    Rectangle {
                        visible: modelData.connected
                        width: 70; height: 30; radius: 15
                        color: "#ff453a20"
                        border.color: "#ff453a"; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "Disconnect"
                            color: "#ff453a"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                btConnectCmd.address = modelData.address
                                btConnectCmd.cmd = "disconnect"
                                btConnectCmd.running = true
                                refreshTimer.restart()
                            }
                        }
                    }
                }
            }
        }
    }
}