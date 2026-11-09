import QtQuick
import QtQuick.Controls
import Quickshell.Io
import "../services" as Services

Item {
    id: dashboardRoot
    property string page: "home"
    property bool pinned: false
    property bool active: false
    anchors.fill: parent

    // Lyrics fetcher state
    property string liveLyricsText: "Loading..."
    property string lastTrackedTitle: ""

    // System volume real-time reader
    property real systemVolumeLevel: 0.50

    Process {
        id: readSystemVolume
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line = text;
                var parts = line.trim().split(" ");
                if (parts.length >= 2) {
                    var val = parseFloat(parts[1]);
                    if (!isNaN(val)) { systemVolumeLevel = val; }
                }
            }
        }
    }

    // Poll volume every 2 seconds to capture hardware button changes
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: readSystemVolume.running = true
    }

    function fmtTime(s) {
        const t = Math.max(0, Math.floor(s))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    // Volume setter process
    Process {
        id: setVolProcess
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.5"]
    }

    function setSystemVolume(vol) {
        setVolProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol.toFixed(2)]
        setVolProcess.running = true;
    }

    // Lyrics fetcher process
    Process {
        id: fetchLyricsProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    if (data && data.lyrics) {
                        dashboardRoot.liveLyricsText = data.lyrics;
                    } else {
                        dashboardRoot.liveLyricsText = "No lyrics found for this track.";
                    }
                } catch(e) {
                    dashboardRoot.liveLyricsText = "No lyrics available.";
                }
            }
        }
    }

    function fetchLyrics(currentArtist, currentTitle) {
        fetchLyricsProcess.command = ["curl", "-s", "https://api.lyrics.ovh/v1/" + encodeURIComponent(currentArtist) + "/" + encodeURIComponent(currentTitle)];
        fetchLyricsProcess.running = true;
    }

    // Auto-fetch hook tracking titles - uses Media service
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (Services.Media.hasPlayer && Services.Media.title !== "") {
                if (Services.Media.title !== lastTrackedTitle) {
                    lastTrackedTitle = Services.Media.title;
                    dashboardRoot.liveLyricsText = "Searching backend...";
                    fetchLyrics(Services.Media.artist, Services.Media.title);
                }
            } else {
                dashboardRoot.liveLyricsText = "None (No active media playing).";
                lastTrackedTitle = "";
            }
        }
    }

    // --- TOP BAR: Navigation Tabs ---
    Rectangle {
        id: tabBar
        x: 20; y: 12
        width: 740; height: 44
        color: "transparent"

        Row {
            anchors.fill: parent
            spacing: 8

            Repeater {
                model: [
                    ["home", "home", "Home"],
                    ["music", "music", "Music"],
                    ["clipboard", "clipboard", "Clipboard"],
                    ["alerts", "bell", "Alerts"],
                    ["shelf", "folder", "Shelf"],
                    ["notes", "notebook", "Notes"],
                    ["controls", "layers", "Controls"],
                    ["bluetooth", "bluetooth", "Bluetooth"]
                ]
                delegate: Item {
                    width: 84; height: 44
                    property string pageId: modelData[0]
                    property string iconName: modelData[1]
                    property string label: modelData[2]
                    property bool isActive: dashboardRoot.page === pageId

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: isActive ? "#3b8bff" : "transparent"
                        border.color: isActive ? "#3b8bff" : "transparent"
                        border.width: isActive ? 1 : 0
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Icon {
                                name: iconName
                                size: 20
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                            Text {
                                text: label
                                font.pixelSize: 9
                                font.bold: true
                                color: isActive ? "#ffffff" : "#9a9aa0"
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: dashboardRoot.page = pageId
                        }
                    }
                }
            }
        }
    }

    // --- UTILITY ROW: Lower icons (aligned with tabs) ---
    Row {
        id: utilityRow
        x: 20; y: 72
        width: 740
        height: 24
        spacing: 8  // Same spacing as tabs

        Repeater {
            model: [
                ["calendar", "calendar", "Calendar"],
                ["search", "search", "Search"],
                ["volume", "volume", "Volume"],
                ["bluetooth", "bluetooth", "Bluetooth"],
                ["activity", "activity", "System"],
                ["settings", "settings", "Settings"]
            ]
            delegate: Item {
                width: 84; height: 24  // Same width as tabs
                property string pageId: modelData[0]
                property string iconName: modelData[1]
                property string label: modelData[2]

                Icon {
                    name: iconName
                    size: 16
                    color: "#9a9aa0"
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: dashboardRoot.page = pageId
                }
            }
        }
    }

    // Separator line below utility row
    Rectangle {
        x: 20; y: 98
        width: 740; height: 1
        color: "#2a2a2e"
    }

    // --- CONTENT AREA: Tab panels ---
    Item {
        x: 20; y: 106
        width: 740
        height: parent.height - 118

        HomeTab { anchors.fill: parent; visible: page === "home" }
        
        // --- MUSIC TAB ---
        Item {
            width: 740
            height: 280
            anchors.horizontalCenter: parent.horizontalCenter
            y: 8
            visible: page === "music"

            Row {
                width: 740
                height: parent.height
                spacing: 20

                // LEFT: Media Engine
                Item {
                    width: 430
                    height: parent.height

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // Track Details - Thumbnail + Title/Artist
                        Row {
                            width: parent.width; height: 110; spacing: 16
                            Rectangle {
                                width: 110; height: 110; radius: 14; color: "#2c2c2e"; clip: true
                                Image {
                                    anchors.fill: parent; fillMode: Image.PreserveAspectCrop
                                    source: Services.Media.artUrl
                                    asynchronous: true
                                    cache: true
                                }
                                Icon { name: "media-playlist-normal"; size: 32; anchors.centerIn: parent; color: "#ffffff"; visible: parent.children[0].status !== Image.Ready }
                            }
                            Column {
                                width: parent.width - 126; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                Text { text: Services.Media.hasPlayer ? Services.Media.title : "Nothing playing"; color: "#ffffff"; font.pixelSize: 16; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                Text { text: Services.Media.artist !== "" ? Services.Media.artist : "Start playing a track..."; color: "#9a9aa0"; font.pixelSize: 13; elide: Text.ElideRight; width: parent.width }
                            }
                        }

                        // Controls
                        Row {
                            width: parent.width; height: 44
                            spacing: (parent.width - (24 + 24 + 40 + 24 + 24)) / 4

                            // Shuffle
                            Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                                Icon { name: "shuffle"; size: 20; color: Services.Media.shuffleOn ? "#3b8bff" : "#9a9aa0"; anchors.centerIn: parent }
                                MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleShuffle() }
                            }
                            // Previous
                            Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                                Icon { name: "media-skip-backward"; size: 24; color: "#9a9aa0"; anchors.centerIn: parent }
                                MouseArea { anchors.fill: parent; onClicked: Services.Media.previous() }
                            }
                            // Play/Pause
                            Item { width: 40; height: 40; anchors.verticalCenter: parent.verticalCenter
                                Icon { name: Services.Media.isPlaying ? "pause" : "play"; size: 32; color: "#ffffff"; anchors.centerIn: parent }
                                MouseArea { anchors.fill: parent; onClicked: Services.Media.togglePlay() }
                            }
                            // Next
                            Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                                Icon { name: "media-skip-forward"; size: 24; color: "#9a9aa0"; anchors.centerIn: parent }
                                MouseArea { anchors.fill: parent; onClicked: Services.Media.next() }
                            }
                            // Repeat
                            Item { width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter
                                Icon { name: "repeat"; size: 20; color: Services.Media.repeatOn ? "#3b8bff" : "#9a9aa0"; anchors.centerIn: parent }
                                MouseArea { anchors.fill: parent; onClicked: Services.Media.toggleRepeat() }
                            }
                        }

                        // Progress Bar
                        Column {
                            width: parent.width; height: 40; spacing: 6
                            Slider {
                                id: trackProgressSlider; width: parent.width; height: 14; value: Services.Media.length > 0 ? Services.Media.position / Services.Media.length : 0
                                background: Rectangle { height: 5; radius: 3; color: "#22ffffff"; Rectangle { width: trackProgressSlider.visualPosition * parent.width; height: 5; color: "#ffffff"; radius: 3 } }
                                handle: Rectangle { x: trackProgressSlider.visualPosition * (trackProgressSlider.width - width); y: -5; width: 14; height: 14; radius: 7; color: "#ffffff" }
                                onValueChanged: {
                                    if (Services.Media.length > 0) {
                                        Services.Media.seek(value * Services.Media.length);
                                    }
                                }
                            }
                            Item {
                                width: parent.width; height: 14
                                Text { text: fmtTime(Services.Media.position); color: "#66ffffff"; font.pixelSize: 11 }
                                Text { text: Services.Media.length > 0 ? fmtTime(Services.Media.length) : "-0:00"; color: "#66ffffff"; font.pixelSize: 11; anchors.right: parent.right }
                            }
                        }

                        // Volume
                        Row {
                            width: parent.width; height: 24; spacing: 12
                            Icon { name: "audio-volume-high"; size: 16; color: "#ffffff" }
                            Slider {
                                id: hardwareVolumeSlider; width: parent.width - 24 - 24; value: systemVolumeLevel; anchors.verticalCenter: parent.verticalCenter
                                background: Rectangle { 
                                    height: 5; radius: 3; color: "#22ffffff"
                                    Rectangle { width: hardwareVolumeSlider.visualPosition * parent.width; height: 5; color: "#3b8bff"; radius: 3 } 
                                }
                                handle: Rectangle { x: hardwareVolumeSlider.visualPosition * (hardwareVolumeSlider.width - width); y: -5; width: 12; height: 12; radius: 6; color: "#ffffff" }
                                onValueChanged: {
                                    systemVolumeLevel = value;
                                    setSystemVolume(value);
                                }
                            }
                        }
                    }
                }

                // RIGHT: Lyrics Card
                Rectangle {
                    width: 290
                    height: parent.height - 16
                    y: 0
                    color: "#16ffffff"
                    border.color: Theme.cardBorder
                    border.width: 1
                    radius: 18
                    clip: true

                    Item {
                        anchors.fill: parent
                        anchors.margins: 18

                        ScrollView {
                            anchors.fill: parent
                            visible: page !== "shelf"
                            Text {
                                width: parent.width
                                text: dashboardRoot.liveLyricsText !== "" ? dashboardRoot.liveLyricsText : "No synced lyrics available"
                                color: "#9a9aa0"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                            }
                        }

                        Column {
                            anchors.fill: parent
                            visible: page === "shelf"
                            spacing: 16

                            Text { text: "Notch File Shelf"; color: "#ffffff"; font.bold: true; font.pixelSize: 15 }

                            Rectangle {
                                width: parent.width; height: 140; radius: 12
                                color: "#11ffffff"; border.color: "#33ffffff"; border.width: 1
                                Column { anchors.centerIn: parent; spacing: 8
                                    Icon { name: "folder-download"; size: 28; color: "#66ffffff" }
                                    Text { text: "Drag files here to stage"; color: "#66ffffff"; font.pixelSize: 12 }
                                }
                            }

                            Text { text: "Staged files copy into ~/Downloads/NotchShelf/ automatically."; color: "#44ffffff"; font.pixelSize: 11; wrapMode: Text.Wrap; width: parent.width }
                        }
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
        Item { visible: page === "search"; anchors.fill: parent; Text { anchors.centerIn: parent; text: "Search"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "volume"; anchors.fill: parent; Text { anchors.centerIn: parent; text: "Volume"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "system"; anchors.fill: parent; Text { anchors.centerIn: parent; text: "Activity"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "settings"; anchors.fill: parent; Text { anchors.centerIn: parent; text: "Settings"; color: Theme.dim; font.pixelSize: 14 } }
        Item { visible: page === "lyrics"; anchors.fill: parent; Text { anchors.centerIn: parent; text: "Lyrics"; color: Theme.dim; font.pixelSize: 14 } }
    }
}