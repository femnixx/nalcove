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

    // Active MPRIS player
    property var activePlayer: Mpris.players.length > 0 ? Mpris.players[0] : null

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
                anchors.margins: 18
                spacing: 14

                // --- SECTION 1: ALBUM ART THUMBNAIL AND TRACK DETAILS ROW ---
                Row {
                    width: parent.width
                    spacing: 14

                    // Fixed Canvas Image Frame for Artwork Thumbnail
                    Rectangle {
                        width: 60; height: 60; radius: 10
                        color: "#161619"
                        border.color: Theme.cardBorder
                        border.width: 1
                        clip: true

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: (activePlayer && activePlayer.metadata && activePlayer.metadata["mpris:artUrl"]) ? activePlayer.metadata["mpris:artUrl"] : "../icons/music.svg"
                        }
                    }

                    // Vertical Track Context Labels
                    Column {
                        width: parent.width - 74
                        spacing: 3
                        
                        Text {
                            text: (activePlayer && activePlayer.metadata && activePlayer.metadata["xesam:title"]) ? activePlayer.metadata["xesam:title"] : "No Media Playing"
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width
                        }
                        Text {
                            text: (activePlayer && activePlayer.metadata && activePlayer.metadata["xesam:artist"]) ? activePlayer.metadata["xesam:artist"].join(", ") : "Unknown Artist"
                            color: "#9a9aa0"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }

                // --- SECTION 2: METRICS TIMELINE WITH ANCHORED LYRICS INTERACTION BUTTON ---
                Item {
                    width: parent.width
                    height: 24

                    // Active Progress Counter
                    Text {
                        id: positionText
                        text: activePlayer ? fmtTime(activePlayer.position) : "0:00"
                        color: "#66ffffff"
                        font.pixelSize: 11
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Responsive Progress Track Line
                    Rectangle {
                        id: progressTrack
                        width: parent.width - 120
                        height: 4
                        radius: 2
                        color: "#22ffffff"
                        anchors.left: positionText.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: (activePlayer && activePlayer.length > 0) ? (activePlayer.position / activePlayer.length) * parent.width : 0
                            height: parent.height
                            radius: 2
                            color: "#3b8bff"
                        }
                    }

                    // Dynamic Spaced Layout: Full Track Duration Display
                    Text {
                        id: durationText
                        text: (activePlayer && activePlayer.length > 0) ? fmtTime(activePlayer.length) : "0:00"
                        color: "#66ffffff"
                        font.pixelSize: 11
                        anchors.left: progressTrack.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Minimal Interactive Floating Lyrics Shortcut (Safely Anchored on the Far Right)
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 42; height: 20; radius: 6
                        color: "#11ffffff"
                        border.color: "#1affffff"

                        Text { text: "Lyrics"; color: "#9a9aa0"; font.pixelSize: 10; font.bold: true; anchors.centerIn: parent }
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: { page = "lyrics" }
                        }
                    }

                    MouseArea {
                        anchors.fill: progressTrack
                        hoverEnabled: true
                        onClicked: (mouse) => { if (activePlayer && activePlayer.length > 0) activePlayer.position = (mouse.x / width) * activePlayer.length }
                        onPositionChanged: (mouse) => { if (pressed && activePlayer && activePlayer.length > 0) activePlayer.position = (mouse.x / width) * activePlayer.length }
                    }
                }

                // --- SECTION 3: SPACED SYSTEM HARDWARE PLAYER MEDIA BACKEND BUTTONS ---
                Row {
                    width: parent.width
                    height: 48
                    spacing: (parent.width - (24 + 48 + 24)) / 2 

                    // Previous Track
                    Rectangle {
                        width: 24; height: 24; color: "transparent"; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "skip-back"; size: 24; color: "#ffffff"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: if (activePlayer) activePlayer.previous() }
                    }

                    // Big Circular Play/Pause Switcher
                    Rectangle {
                        width: 48; height: 48; radius: 24
                        color: "#3b8bff"
                        anchors.verticalCenter: parent.verticalCenter

                        Icon { 
                            name: (activePlayer && activePlayer.playbackStatus === Mpris.Playing) ? "pause" : "play"
                            size: 22 
                            color: "#ffffff"
                            anchors.centerIn: parent 
                        }
                        MouseArea { 
                            id: playMouseArea
                            anchors.fill: parent
                            onClicked: if (activePlayer) activePlayer.togglePlay()
                        }
                        scale: playMouseArea.pressed ? 0.95 : 1
                        Behavior on scale { SpringAnimation { spring: 2; damping: 0.3 } }
                    }

                    // Next Track
                    Rectangle {
                        width: 24; height: 24; color: "transparent"; anchors.verticalCenter: parent.verticalCenter
                        Icon { name: "skip-forward"; size: 24; color: "#ffffff"; anchors.centerIn: parent }
                        MouseArea { anchors.fill: parent; onClicked: if (activePlayer) activePlayer.next() }
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