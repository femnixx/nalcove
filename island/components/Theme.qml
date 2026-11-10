pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // NotchX glass theme
    readonly property bool glass: true
    readonly property color islandFill: glass ? "#f2101013" : "#000000"
    readonly property color border: glass ? "#1fffffff" : "#000000"
    readonly property color card: glass ? "#0fffffff" : "#161619"
    readonly property color cardBorder: glass ? "#14ffffff" : "#161619"
    readonly property color cardHi: glass ? "#1fffffff" : "#2c2c30"
    readonly property color fg: "#ffffff"
    readonly property color dim: "#9a9aa0"
    readonly property color accent: "#3b8bff"
    readonly property color accentFill: "#2a3b8bff"
    readonly property color good: "#34c759"
    readonly property color track: "#3a3a3c"
    readonly property real cardRadius: 18
    readonly property real pillRadius: 12
    readonly property string fontFamily: "Inter"
    readonly property real sizeTitle: 15
    readonly property real sizeBody: 12
    readonly property real sizeCaption: 11
    readonly property real sizeClock: 36
}
