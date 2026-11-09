import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower
import Quickshell.Services.Mpris

Item {
    id: dashboardRoot
    property string page: "home"
    property bool pinned: false
    property bool active: false
    anchors.fill: parent

    // Target the primary active player instance safely
    property var activePlayer: (Mpris.players && Mpris.players.length > 0) ? Mpris.players[0] : null

    // Safe battery backing variables
    property string batPercentStr: "78"
    property int batPercentNum: 78
    property bool isCharging: false

    // Timer to poll UPower values - find any battery device
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            updateBatteryInfo();
        }
        Component.onCompleted: {
            updateBatteryInfo();
        }
    }

    function updateBatteryInfo() {
        var found = false;
        if (UPower.devices) {
            for (var i = 0; i < UPower.devices.length; i++) {
                var dev = UPower.devices[i];
                if (dev.ready && dev.type !== 0) { // Not line power (0)
                    if (dev.type === 2 || dev.type === 1 || dev.type === 3) {
                        var pct = Math.round(dev.percentage * 100);
                        dashboardRoot.batPercentStr = pct.toString();
                        dashboardRoot.batPercentNum = pct;
                        dashboardRoot.isCharging = (dev.isCharging === true);
                        found = true;
                        console.log("Found battery device: type=" + dev.type + " name=" + dev.name + " percent=" + pct);
                        break;
                    }
                }
            }
        }
        if (!found && UPower.displayDevice && UPower.displayDevice.ready) {
            var pct = Math.round(UPower.displayDevice.percentage * 100);
            dashboardRoot.batPercentStr = pct.toString();
            dashboardRoot.batPercentNum = pct;
            dashboardRoot.isCharging = (UPower.displayDevice.isCharging === true);
            console.log("Using displayDevice: percent=" + pct);
        }
        if (UPower.devices && dashboardRoot.batPercentNum === 78) {
            for (var j = 0; j < UPower.devices.length; j++) {
                var d = UPower.devices[j];
                console.log("Device " + j + ": type=" + d.type + " name=" + d.name + " ready=" + d.ready + " percent=" + (d.percentage * 100) + " charging=" + d.isCharging);
            }
        }
    }

    function fmtTime(us) {
        const t = Math.max(0, Math.floor(us / 1000000))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    Rectangle {
        x: 20; y: 14
        width: 740; height: 96
        color: "transparent"
        border.color: Theme.border
        border.width: 1
        radius: 14

        // --- ROW 1: TOP NAVIGATION ICONS ---
        Row {
            x: 16; y: 8
            spacing: 8
            
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "home" ? Theme.accentFill : "transparent"
                border.color: page === "home" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "home"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "home" }
            }
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "music" ? Theme.accentFill : "transparent"
                border.color: page === "music" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "music"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "music" }
            }
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "clipboard" ? Theme.accentFill : "transparent"
                border.color: page === "clipboard" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "clipboard"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "clipboard" }
            }
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "alerts" ? Theme.accentFill : "transparent"
                border.color: page === "alerts" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "bell"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "alerts" }
            }
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "shelf" ? Theme.accentFill : "transparent"
                border.color: page === "shelf" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "folder"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "shelf" }
            }
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "notes" ? Theme.accentFill : "transparent"
                border.color: page === "notes" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "notebook"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "notes" }
            }
            Rectangle {
                width: 44; height: 36; radius: 8
                color: page === "controls" ? Theme.accentFill : "transparent"
                border.color: page === "controls" ? Theme.accent : "transparent"; border.width: 1
                Icon { name: "layers"; size: 20; anchors.centerIn: parent; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "controls" }
            }
        }

        // --- ROW 1 RIGHT-SIDE: BATTERY & CLOCK ---
        Row {
            x: 480; y: 16
            spacing: 12

            Text {
                text: Qt.formatDateTime(Clock.now, "ddd d MMM  h:mm AP")
                color: Theme.dim
                font.pixelSize: 13
            }

            Text {
                text: dashboardRoot.batPercentStr + "%"
                color: dashboardRoot.isCharging ? Theme.good : (dashboardRoot.batPercentNum < 20 ? "#ff453a" : Theme.fg)
                font.pixelSize: 13
                font.bold: true
            }

            Icon {
                name: dashboardRoot.isCharging ? "battery-charge" : "battery"
                size: 16
                color: dashboardRoot.isCharging ? Theme.good : (dashboardRoot.batPercentNum < 20 ? "#ff453a" : Theme.fg)
            }
        }

        // --- ROW 2: INNER SECTION LINE ---
        Rectangle {
            x: 0; y: 52
            width: 740; height: 1
            color: Theme.cardBorder
        }

        // --- ROW 3: UTILITY NAVIGATION ICONS ---
        Row {
            x: 16; y: 64
            width: 700
            spacing: 24

            Rectangle {
                width: 20; height: 20; color: "transparent"
                Icon { name: "calendar"; size: 16; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "calendar" }
            }
            Rectangle {
                width: 20; height: 20; color: "transparent"
                Icon { name: "search"; size: 16; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "search" }
            }
            Rectangle {
                width: 20; height: 20; color: "transparent"
                Icon { name: "volume"; size: 16; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "volume" }
            }
            Rectangle {
                width: 20; height: 20; color: "transparent"
                Icon { name: "bluetooth"; size: 16; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "bluetooth" }
            }
            Rectangle {
                width: 20; height: 20; color: "transparent"
                Icon { name: "activity"; size: 16; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "system" }
            }
            Rectangle {
                width: 20; height: 20; color: "transparent"
                Icon { name: "settings"; size: 16; color: Theme.fg }
                MouseArea { anchors.fill: parent; onClicked: page = "settings" }
            }
        }
    }

    // --- CONTENT AREA: Tab panels ---
    Item {
        x: 20; y: 124
        width: 740
        height: parent.height - 144

        HomeTab { anchors.fill: parent; visible: page === "home" }
        
        // --- SIMPLIFIED MEDIA PLAYER (INLINE) ---
        Item {
            anchors.fill: parent
            visible: page === "music"

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // --- TRACK DETAILS ROW ---
                Row {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        width: 52; height: 52; radius: 10
                        color: "#2c2c2e"
                        clip: true
                        
                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            // Safe string conversion fallback
                            source: (dashboardRoot.activePlayer && dashboardRoot.activePlayer.metadata && dashboardRoot.activePlayer.metadata["mpris:artUrl"]) ? String(dashboardRoot.activePlayer.metadata["mpris:artUrl"]) : "../icons/music.svg"
                        }
                    }

                    Column {
                        width: parent.width - 66
                        spacing: 2
                        
                        Text {
                            text: (dashboardRoot.activePlayer && dashboardRoot.activePlayer.metadata && dashboardRoot.activePlayer.metadata["xesam:title"]) ? String(dashboardRoot.activePlayer.metadata["xesam:title"]) : "Spotify / Browser Idle"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Text {
                            text: (dashboardRoot.activePlayer && dashboardRoot.activePlayer.metadata && dashboardRoot.activePlayer.metadata["xesam:artist"]) ? String(dashboardRoot.activePlayer.metadata["xesam:artist"]) : "Start playing a track..."
                            color: "#9a9aa0"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }

                // --- DURATIONS & LYRICS REGION ---
                Item {
                    width: parent.width
                    height: 20

                    Text {
                        id: posLabel
                        text: dashboardRoot.activePlayer ? Math.floor(dashboardRoot.activePlayer.position / 60000) + ":" + String(Math.floor((dashboardRoot.activePlayer.position % 60000) / 1000)).padStart(2, '0') : "0:00"
                        color: "#66ffffff"
                        font.pixelSize: 10
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: trackBar
                        width: parent.width - 130
                        height: 4
                        radius: 2
                        color: "#22ffffff"
                        anchors.left: posLabel.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: (dashboardRoot.activePlayer && dashboardRoot.activePlayer.length > 0) ? (dashboardRoot.activePlayer.position / dashboardRoot.activePlayer.length) * parent.width : 0
                            height: parent.height
                            radius: 2
                            color: "#3b8bff"
                        }
                    }

                    Text {
                        id: durLabel
                        text: (dashboardRoot.activePlayer && dashboardRoot.activePlayer.length > 0) ? Math.floor(dashboardRoot.activePlayer.length / 60000) + ":" + String(Math.floor((dashboardRoot.activePlayer.length % 60000) / 1000)).padStart(2, '0') : "3:45"
                        color: "#66ffffff"
                        font.pixelSize: 10
                        anchors.left: trackBar.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 44; height: 18; radius: 5
                        color: "#16ffffff"
                        border.color: "#22ffffff"

                        Text { text: "Lyrics"; color: "#ffffff"; font.pixelSize: 9; font.bold: true; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: page = "lyrics" }
                    }
                }

                // --- BUTTON ROW (FORCED WHITE OVERLAYS) ---
                Row {
                    width: parent.width
                    height: 40
                    spacing: (parent.width - (24 + 40 + 24)) / 2

                    Rectangle {
                        width: 24; height: 24; color: "transparent"; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "skip-back"; size: 24; color: "#ffffff"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: if (dashboardRoot.activePlayer) dashboardRoot.activePlayer.previous() }
                    }

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#3b8bff"
                        anchors.verticalCenter: parent.verticalCenter

                        Icon { 
                            name: (dashboardRoot.activePlayer && dashboardRoot.activePlayer.playbackStatus === 1) ? "pause" : "play"
                            size: 18 
                            color: "#ffffff"
                            anchors.centerIn: parent 
                        }
                        MouseArea { anchors.fill: parent; onClicked: if (dashboardRoot.activePlayer) dashboardRoot.activePlayer.togglePlay() }
                    }

                    Rectangle {
                        width: 24; height: 24; color: "transparent"; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "skip-forward"; size: 24; color: "#ffffff"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: if (dashboardRoot.activePlayer) dashboardRoot.activePlayer.next() }
                    }
                }
            }
        }

        ClipboardTab { anchors.fill: parent; visible: page === "clipboard" }
        AlertsTab { anchors.fill: parent; visible: page === "alerts" }
        ShelfTab { anchors.fill: parent; visible: page === "shelf" }
        NotesTab { anchors.fill: parent; visible: page === "notes" }
        CalendarTab { anchors.fill: parent; visible: page === "calendar" }
        ControlsTab { anchors.fill: parent; visible: page === "controls" }
        BluetoothTab { anchors.fill: parent; visible: page === "bluetooth" }

        // Placeholder tabs
        Item { visible: page === "search"; anchors.fill: parent
            Text { anchors.centerIn: parent; text: "Search"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "system"; anchors.fill: parent
            Text { anchors.centerIn: parent; text: "Activity"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "settings"; anchors.fill: parent
            Text { anchors.centerIn: parent; text: "Settings"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "lyrics"; anchors.fill: parent
            Text { anchors.centerIn: parent; text: "Lyrics"; color: Theme.dim; font.pixelSize: 14 } }
    }
}