// island/components/Theme.qml - Singleton: colors, sizes, durations, spring values
// Usage: import "components" (auto-available via singleton)

pragma Singleton
import QtQuick 2.15

QtObject {
    // ===== Colors =====
    readonly property color bg: "#f2101013"           // island fill
    readonly property color card: "#0fffffff"         // card surface
    readonly property color cardHi: "#1fffffff"       // raised/hover card
    readonly property color cardBorder: "#14ffffff"   // hairline border
    readonly property color fg: "#ffffff"             // primary text
    readonly property color dim: "#9a9aa0"            // secondary text
    readonly property color faint: "#44ffffff"        // tertiary/muted text
    readonly property color accent: "#3b8bff"         // primary accent
    readonly property color accentSoft: "#2a3b8bff"   // accent ~18% alpha
    readonly property color danger: "#ff453a"         // destructive
    readonly property color dangerSoft: "#33ff453a"   // danger ~20% alpha
    readonly property color success: "#34c759"        // success/connected
    readonly property color track: "#2a2a2e"          // slider track
    readonly property color border: "#1fffffff"       // generic border
    readonly property color overlay: "#000000"        // scrim for compact/peek

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
    readonly property int flareRadius: 12
    readonly property int expandedBottomRadius: 32

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
    readonly property int windowWidth: 780
    readonly property int windowHeight: 470
    readonly property int overshootMargin: 0
    readonly property int hoverBottomRadius: 24

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