import QtQuick

/*
 * DynamicNotch: a dynamic-island style container with three states.
 *   collapsed -> small pill (idle)
 *   compact   -> wider "live activity" strip (music, volume, notification...)
 *   expanded  -> full panel with your tabs
 *
 * Behavior:
 *   - hover expands it (after a short delay), leaving collapses it
 *   - click toggles it
 *   - notch.peek() pops the compact strip for a few seconds, then returns to
 *     the pill (call it from volume changes, new track, notifications...)
 *   - sizes animate with a spring, content fades in/out
 *   - content lives in Loaders and is DESTROYED after it fades out, so a
 *     collapsed notch holds almost no memory
 *
 * Usage inside your PanelWindow (put it in the same folder as your pages):
 *
 *   PanelWindow {
 *       anchors.top: true
 *       exclusionMode: ExclusionMode.Ignore
 *       color: "transparent"
 *       implicitWidth: notch.expandedW + 60
 *       implicitHeight: notch.expandedH + 40
 *       mask: Region { item: notch }          // clicks outside the notch pass through
 *
 *       DynamicNotch {
 *           id: notch
 *           anchors.horizontalCenter: parent.horizontalCenter
 *           anchors.top: parent.top
 *           collapsedContent: Component { Text { anchors.centerIn: parent; text: "12:56"; color: "#fff" } }
 *           compactContent:   Component { Text { anchors.centerIn: parent; text: "Now playing"; color: "#fff" } }
 *           expandedContent:  Component { YourTabHost { anchors.fill: parent } }
 *       }
 *   }
 *
 * Peek on events (adjust the signal name to your service):
 *   Connections { target: Services.Audio; function onSinkVolumeChanged() { notch.peek() } }
 */
Item {
    id: root

    // ---- public API ------------------------------------------------------
    property string mode: "collapsed"      // collapsed | compact | expanded
    readonly property bool expanded: mode === "expanded"

    property bool hoverExpands: true
    property int hoverDelay: 140           // ms hovering before it expands
    property int leaveDelay: 350           // ms after leaving before it collapses
    property int peekDuration: 3500        // ms a compact peek stays visible

    property int collapsedW: 190
    property int collapsedH: 34
    property int compactW: 320
    property int compactH: 46
    property int expandedW: 760
    property int expandedH: 420
    property int pad: 16                   // inner padding of the expanded panel

    property color fill: "#000000"
    property bool flushTop: true           // square top corners (attached to screen edge)

    property Component collapsedContent: null
    property Component compactContent: null
    property Component expandedContent: null

    function expand()   { collapseTimer.stop(); mode = "expanded" }
    function collapse() { expandTimer.stop(); peekTimer.stop(); mode = "collapsed" }
    function toggle()   { if (expanded) collapse(); else expand() }
    function peek(ms) {
        if (expanded) return
        mode = "compact"
        peekTimer.interval = ms > 0 ? ms : peekDuration
        peekTimer.restart()
    }

    // ---- size and shape (spring animated) --------------------------------
    width: mode === "expanded" ? expandedW : (mode === "compact" ? compactW : collapsedW)
    height: mode === "expanded" ? expandedH : (mode === "compact" ? compactH : collapsedH)
    clip: true

    // Lower damping = more bounce. Raise it if the overshoot gets clipped by your window.
    Behavior on width  { SpringAnimation { spring: 3.2; damping: 0.32; epsilon: 0.25 } }
    Behavior on height { SpringAnimation { spring: 3.2; damping: 0.32; epsilon: 0.25 } }

    property real cornerRadius: mode === "expanded" ? 30 : (mode === "compact" ? compactH / 2 : collapsedH / 2)
    Behavior on cornerRadius { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.fill
    }
    Rectangle {                              // squares off the top corners
        visible: root.flushTop
        anchors.top: parent.top
        width: parent.width
        height: root.cornerRadius
        color: root.fill
    }

    // ---- input -----------------------------------------------------------
    // Sits under all content, so buttons and sliders inside still get their own clicks.
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.toggle()
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                collapseTimer.stop()
                peekTimer.stop()
                if (root.hoverExpands && !root.expanded) expandTimer.restart()
            } else {
                expandTimer.stop()
                if (root.expanded) collapseTimer.restart()
                else if (root.mode === "compact") peekTimer.restart()
            }
        }
    }

    Timer { id: expandTimer;   interval: root.hoverDelay; onTriggered: if (hover.hovered) root.expand() }
    Timer { id: collapseTimer; interval: root.leaveDelay; onTriggered: if (!hover.hovered) root.collapse() }
    Timer { id: peekTimer;     onTriggered: if (!hover.hovered && root.mode === "compact") root.collapse() }

    // ---- content ---------------------------------------------------------
    // Each Loader has a FIXED size, so nothing re-lays out while the notch is
    // animating (the clip just reveals more or less of it). Each one is
    // destroyed once it has faded out.
    Loader {
        id: collapsedLoader
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.collapsedW
        height: root.collapsedH
        sourceComponent: root.collapsedContent
        opacity: root.mode === "collapsed" ? 1 : 0
        active: root.mode === "collapsed" || opacity > 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 110 } }
    }

    Loader {
        id: compactLoader
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.compactW
        height: root.compactH
        sourceComponent: root.compactContent
        opacity: root.mode === "compact" ? 1 : 0
        active: root.mode === "compact" || opacity > 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 130 } }
    }

    Loader {
        id: expandedLoader
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.pad
        width: root.expandedW - root.pad * 2
        height: root.expandedH - root.pad * 2
        sourceComponent: root.expandedContent
        opacity: root.mode === "expanded" ? 1 : 0
        active: root.mode === "expanded" || opacity > 0
        visible: opacity > 0
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: root.mode === "expanded" ? 90 : 0 }   // fade in after it grows
                NumberAnimation { duration: 160 }
            }
        }
    }
}
