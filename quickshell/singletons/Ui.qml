pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property string panel: ""
    property string screenName: ""
    property bool locked: false
    property string osd: ""            // "volume" | "brightness" | "mic"
    property bool osdMuted: false
    property int osdBrightness: 50
    property int osdPercent: 0

    property int desktopEditRequest: 0
    property real wallpaperTransition: 0
    property string wallpaperTransitionImage: ""

    function startWallpaperTransition(path) {
        wallpaperTransitionImage = path || "";
        wallpaperTransition = 1;
        wpAnim.restart();
    }

    function open(name, screen) {
        root.screenName = screen !== undefined ? screen : "";
        root.panel = name;
        root.osd = "";
    }

    function close() {
        root.panel = "";
        root.screenName = "";
    }

    function toggle(name, screen) {
        if (root.panel === name) {
            root.close();
            return;
        }
        root.open(name, screen);
    }

    function showOn(name, screen) {
        if (root.panel === name && (screen === undefined || root.screenName === screen))
            return;
        root.open(name, screen);
    }

    function lock() {
        root.panel = "";
        root.osd = "";
        root.locked = true;
    }

    function unlock() {
        root.locked = false;
    }

    function showOsd(kind, percent, muted) {
        root.osdMuted = muted === true;
        root.osdPercent = Math.round(Number(percent) || 0);
        root.osd = kind;
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1400
        onTriggered: root.osd = ""
    }

    NumberAnimation {
        id: wpAnim
        target: root
        property: "wallpaperTransition"
        from: 1
        to: 0
        duration: Math.max(0, Settings.data.wallpaperTransitionMs || 700)
        easing.type: Easing.InOutCubic
        onFinished: root.wallpaperTransitionImage = ""
    }
}
