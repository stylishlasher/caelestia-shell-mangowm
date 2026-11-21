pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.I18n

Singleton {
    id: root

    // MangoWC shim exposing the subset of Caelestia Hypr API used by the shell.
    property var toplevels: ({ values: [] })
    property var workspaces: ({ values: [] })
    property var monitors: ({ values: [] })
    property bool usingLua: false

    property var activeToplevel: null
    property var focusedWorkspace: _mkWs(1)
    property var focusedMonitor: _mkMon("", focusedWorkspace)
    property int activeWsId: focusedWorkspace?.id ?? 1

    property var keyboard: null
    property bool capsLock: false
    property bool numLock: false
    property string defaultKbLayout: "us"
    property string kbLayoutFull: "English (US)"
    property string kbLayout: "US"
    property var kbMap: new Map()

    property var extras: ({ devices: ({ keyboards: [] }), options: ({}), batchMessage: function(_) {}, message: function(_) {}, refreshOptions: function() {}, refreshDevices: function() {} })
    property var options: extras.options
    property var devices: extras.devices

    property string lastSpecialWorkspace: ""
    signal configReloaded()

    function _mkWs(id) {
        const n = String(id || 1);
        const ws = { id: Number(id || 1), name: n, lastIpcObject: { windows: 0, name: n }, toplevels: ({ values: [] }) };
        return ws;
    }
    function _mkMon(name, ws) {
        const n = String(name || (Quickshell.screens[0]?.name || ""));
        return {
            name: n, id: 0,
            activeWorkspace: ws, focusedWorkspace: ws,
            lastIpcObject: { specialWorkspace: { name: "" }, name: n, focusedWorkspace: { id: ws?.id ?? 1 } }
        };
    }

    function dispatch(request) {
        const r = String(request || "");
        if (!r) return;
        if (r.startsWith("workspace ")) {
            const ws = r.split(/\s+/)[1];
            if (ws) Quickshell.execDetached(["mmsg","-t", String(ws)]);
            return;
        }
        if (r.includes("togglespecialworkspace")) return;
        if (r.startsWith("focuswindow")) return;
    }
    function focusWorkspace(ws) { dispatch("workspace " + ws); }
    function toggleSpecial(name) { lastSpecialWorkspace = name ? "special:" + name : lastSpecialWorkspace; }
    function cycleSpecialWorkspace(direction) {}
    function monitorNames() { return Quickshell.screens.map(s => s.name); }
    function monitorFor(screen) {
        const name = screen?.name || (Quickshell.screens[0]?.name || "");
        return _mkMon(name, root.focusedWorkspace);
    }
    function trimWsName(name) { return name && String(name).startsWith("special:") ? String(name).slice(8) : String(name || ""); }
    function toplevelsForWs(ws, ignoredTags) { return []; }
    function isToplevelIgnored(toplevel, ignoredTags) { return false; }
    function reloadDynamicConfs() {}

    function refreshFromMmsg(text) {
        try {
            // mmsg -g -t format can vary; best-effort parse active tag
            const line = String(text || "");
            let m = line.match(/tag\s+(\d+)\s+1/);
            if (!m) m = line.match(/^\S+\s+tag\s+(\d+)\s+1/);
            if (m) {
                const id = parseInt(m[1]);
                if (!isNaN(id) && id > 0) {
                    const ws = _mkWs(id);
                    root.focusedWorkspace = ws;
                    root.activeWsId = id;
                    root.focusedMonitor = _mkMon(root.focusedMonitor?.name || "", ws);
                }
            }
        } catch(e) {}
    }

    Process {
        id: wsProc
        command: ["sh","-c","mmsg -g -t 2>/dev/null | head -n 40"]
        stdout: SplitParser { splitMarker: "\n"; onRead: data => root.refreshFromMmsg(data) }
    }
    Timer { interval: 1500; running: true; repeat: true; onTriggered: if (!wsProc.running) wsProc.running = true }
    Component.onCompleted: wsProc.running = true
}
