// island/components/Style.qml - Singleton: shared UI building blocks
// Usage: import qs.components 1.0

pragma Singleton
import QtQuick 2.15

QtObject {
    // ===== Colors =====
    readonly property color islandFill: "#f2101013"
    readonly property color bg: "#f2101013"
    readonly property color card: "#0fffffff"
    readonly property color cardBorder: "#14ffffff"
    readonly property color cardHi: "#1fffffff"
    readonly property color fg: "#ffffff"
    readonly property color dim: "#9a9aa0"
    readonly property color accent: "#3b8bff"
    readonly property color accentSoft: "#2a3b8bff"
    readonly property color good: "#34c759"
    readonly property color track: "#2a2a2e"
    readonly property color border: "#1fffffff"
    readonly property color overlay: "#000000"

    // ===== Spacing scale (8px grid) =====
    readonly property int s1: 4
    readonly property int s2: 8
    readonly property int s3: 12
    readonly property int s4: 16
    readonly property int s5: 24

    // ===== Radii =====
    readonly property int rSm: 8
    readonly property int rMd: 12
    readonly property int rLg: 18
    readonly property int cardRadius: 18
    readonly property int pillRadius: 12
    readonly property int flareRadius: 12
    readonly property int expandedBottomRadius: 32
    readonly property int hoverBottomRadius: 24
    readonly property int idleBottomRadius: 0

    // ===== Typography =====
    readonly property string fontFamily: "Inter, Roboto, Noto Sans, sans-serif"
    readonly property int tTitle: 16
    readonly property int tBody: 13
    readonly property int tSmall: 11
    readonly property int tCaption: 10
    readonly property int tClock: 36

    // ===== Motion =====
    readonly property int dFast: 120
    readonly property int dBase: 180
    readonly property string easingOutCubic: "OutCubic"

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

    // ===== Sizes (width x height) =====
    readonly property int idleWidth: 200
    readonly property int idleHeight: 34
    readonly property int hoverWidth: 360
    readonly property int hoverHeight: 80
    readonly property int notifyWidth: 420
    readonly property int notifyHeight: 120
    readonly property int expandedWidth: 780
    readonly property int expandedHeight: 400
readonly property int windowWidth: Style.expandedWidth + 2 * Style.flareRadius + Style.overshootMargin
readonly property int windowHeight: Style.windowHeight
    readonly property int overshootMargin: 0

    // ===== UI constants =====
    readonly property int iconSm: 14
    readonly property int iconMd: 18
    readonly property int iconLg: 24
    readonly property int rowH: 36
    readonly property int controlH: 32
    readonly property int hoverDebounceMs: 150
    readonly property int contentFadeInMs: 180
    readonly property int contentFadeDelayMs: 80

    readonly property bool glass: true
}