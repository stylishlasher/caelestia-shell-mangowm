pragma Singleton
import QtQuick
import Quickshell
import "." as C

Singleton {
    id: root
    // Caelestia plugin exposes GlobalConfig as the live config object.
    // Bridge to our Config shim.
    readonly property var appearance: C.Config.appearance
    readonly property var general: C.Config.general
    readonly property var background: C.Config.background
    readonly property var border: C.Config.border
    readonly property var services: C.Config.services
    readonly property var utilities: C.Config.utilities
    readonly property var bar: C.Config.bar
    readonly property var dashboard: C.Config.dashboard
    readonly property var launcher: C.Config.launcher
    readonly property var notifs: C.Config.notifs
    readonly property var osd: C.Config.osd
    readonly property var session: C.Config.session
    readonly property var sidebar: C.Config.sidebar
    readonly property var lock: C.Config.lock
    readonly property var nexus: C.Config.nexus
    readonly property var winfo: C.Config.winfo
    readonly property var paths: C.Config.paths

    // Screen-specific API fallback
    function forScreen(name) { return C.Config; }
}
