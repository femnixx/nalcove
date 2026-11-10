import QtQuick

Item {
    id: root
    property string name: ""
    property color color: "#ffffff"
    property int size: 16

    width: size
    height: size

    // Unified icon font: FiraMono Nerd Font (installed via otf-firamono-nerd)
    // All icon names used across the project map to glyphs in this single font.
    readonly property var glyphMap: {
        "bell": "\uF0F3",
        "bluetooth": "\uF293",
        "copy": "\uF4BB",
        "file": "\uF15B",
        "lock": "\uF023",
        "media-playlist-normal": "\uF03A",
        "media-skip-backward": "\uF048",
        "media-skip-forward": "\uF051",
        "pause": "\uF04C",
        "play": "\uF04B",
        "repeat": "\uF01E",
        "search": "\uF002",
        "shuffle": "\uF074",
        "sun": "\u263C",
        "trash": "\uF48E",
        "volume": "\uF028",
        "wifi": "\uF1EB",
        "x": "\uF00D",
        "zap": "\u26A1",
        // Weather icons
        "cloud": "\uF0C2",
        "cloud-rain": "\uEF1C",
        "cloud-snow": "\uF0598",
        "cloud-lightning": "\uEF2C",
        "cloud-fog": "\uF0591",
        // State indicators
        "hovered": "\u25CF",
        "pressed": "\uF110",
    }

    // Font glyph when name is mapped; SVG fallback otherwise
    readonly property bool useFont: !!root.glyphMap[root.name]

    Text {
        id: fontIcon
        anchors.fill: parent
        text: root.useFont ? root.glyphMap[root.name] : ""
        font.family: "FiraMono Nerd Font"
        font.pixelSize: root.size
        color: root.color
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
        visible: root.useFont
    }

    Image {
        id: svgFallback
        source: "../icons/" + root.name + ".svg"
        anchors.fill: parent
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectFit
        mipmap: true
        visible: !root.useFont
        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("Icon missing: " + root.name)
            }
        }
    }
}
