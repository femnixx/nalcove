// island/Theme.qml - Singleton: colors, sizes, durations, spring values
// Usage: import Island 1.0 as Theme

pragma Singleton
import QtQuick 2.15

QtObject {
    // Colors
    readonly property color islandFill: "#000000"
    readonly property color shadowColor: "#40000000"

    // Sizes (width x height)
    readonly property int idleWidth: 200
    readonly property int idleHeight: 34
    readonly property int hoverWidth: 360
    readonly property int hoverHeight: 80
    readonly property int expandedWidth: 640
    readonly property int expandedHeight: 220

    // Corner radii
    readonly property int idleBottomRadius: 14
    readonly property int hoverBottomRadius: 28
    readonly property int expandedBottomRadius: 28
    readonly property int flareRadius: 12

    // Overshoot margin for spring physics
    readonly property int overshootMargin: 40

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

    // Window fixed size (expanded + overshoot margin on all sides)
    readonly property int windowWidth: Theme.expandedWidth + Theme.overshootMargin * 2
    readonly property int windowHeight: Theme.expandedHeight + Theme.overshootMargin * 2
}
