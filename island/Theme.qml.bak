// island/Theme.qml - Singleton: colors, sizes, durations, spring values
// Usage: import Island 1.0 as Theme

pragma Singleton
import QtQuick 2.15

QtObject {
    // Colors
    readonly property color islandFill: "#f2101013"
    readonly property color border: "#1fffffff"
    readonly property color card: "#0fffffff"
    readonly property color cardBorder: "#14ffffff"
    readonly property color cardHi: "#1fffffff"
    readonly property color fg: "#ffffff"
    readonly property color dim: "#9a9aa0"
    readonly property color accent: "#3b8bff"
    readonly property color accentFill: "#2a3b8bff"
    readonly property color good: "#34c759"
    readonly property color track: "#2a2a2e"

    // Radii
    readonly property int cardRadius: 18
    readonly property int pillRadius: 12
    readonly property int flareRadius: 12
    readonly property int expandedBottomRadius: 32

    // Typography
    readonly property string fontFamily: "Inter, Roboto, Noto Sans, sans-serif"
    readonly property int title: 15
    readonly property int body: 12
    readonly property int caption: 11
    readonly property int clock: 36

    // Sizes (width x height)
    readonly property int idleWidth: 200
    readonly property int idleHeight: 34
    readonly property int hoverWidth: 360
    readonly property int hoverHeight: 80
    readonly property int expandedWidth: 780
    readonly property int expandedHeight: 400

    // Timings
    readonly property int hoverDebounceMs: 150
    readonly property int contentFadeInMs: 180
    readonly property int contentFadeDelayMs: 80

    // Spring animation tuning
    readonly property real springWidth: 3.5
    readonly property real dampingWidth: 0.35
    readonly property real epsilonWidth: 0.25

    readonly property real springHeight: 3.5
    readonly property real dampingHeight: 0.35
    readonly property real epsilonHeight: 0.25

    readonly property real springRadius: 3.0
    readonly property real dampingRadius: 0.4
    readonly property real epsilonRadius: 0.1

    readonly property bool glass: true
}