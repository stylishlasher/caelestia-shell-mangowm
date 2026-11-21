pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Live compositor state, sourced from mmsg ---------------------------------
    property var monitors: []
    property var clients: []
    property string layout: "us"
    property bool ready: false

    readonly property bool available: monitorProc.running
    readonly property var focusedMonitor: {
        const list = root.monitors || [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].active)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }
    readonly property string focusedName: focusedMonitor ? (focusedMonitor.name || "") : ""
    readonly property string focusedLayout: focusedMonitor ? (focusedMonitor.layout_symbol || "") : ""

    function monitorByName(name) {
        const list = root.monitors || [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].name === name)
                return list[i];
        }
        return null;
    }

    function tagsFor(name) {
        const monitor = monitorByName(name);
        return monitor && monitor.tags ? monitor.tags : [];
    }

    function activeTagsFor(name) {
        const monitor = monitorByName(name);
        return monitor && monitor.active_tags ? monitor.active_tags : [];
    }

    function occupiedClients(name) {
        const list = root.clients || [];
        let count = 0;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].monitor === name && !list[i].is_minimized)
                count++;
        }
        return count;
    }

    function clientsFor(name) {
        const list = root.clients || [];
        const result = [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].monitor === name)
                result.push(list[i]);
        }
        return result;
    }

    function runDispatch(args) {
        Quickshell.execDetached(["mmsg", "dispatch", args]);
    }

    function view(name, index) {
        runDispatch("viewcrossmon," + index + "," + name);
    }

    function tagWindow(name, index) {
        runDispatch("tagcrossmon," + index + "," + name);
    }

    function focusMonitor(name) {
        runDispatch("focusmon," + name);
    }

    function focusClient(id) {
        runDispatch("focusid,client," + id);
    }

    function toggleFloating() {
        runDispatch("togglefloating");
    }

    function centerWindow() {
        runDispatch("centerwin");
    }

    function closeWindow() {
        runDispatch("killclient");
    }

    function quitCompositor() {
        runDispatch("quit");
    }

    function nextLayout() {
        runDispatch("switch_layout");
    }

    // Watchers ----------------------------------------------------------------
    Process {
        id: monitorProc
        command: ["mmsg", "watch", "all-monitors"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data);
                    if (parsed && parsed.monitors) {
                        root.monitors = parsed.monitors;
                        root.ready = true;
                    }
                } catch (e) {
                }
            }
        }

        onExited: {
            root.ready = false;
        }
    }

    Process {
        id: clientProc
        command: ["mmsg", "watch", "all-clients"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data);
                    if (parsed && parsed.clients)
                        root.clients = parsed.clients;
                } catch (e) {
                }
            }
        }
    }

    Process {
        id: layoutProc
        command: ["mmsg", "watch", "keyboardlayout"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data);
                    if (parsed && typeof parsed.layout === "string")
                        root.layout = parsed.layout;
                } catch (e) {
                }
            }
        }
    }

    // Retry starting the watchers if the compositor IPC socket appears later.
    Timer {
        interval: 4000
        repeat: true
        running: !root.available
        onTriggered: {
            if (!monitorProc.running)
                monitorProc.running = true;
            if (!clientProc.running)
                clientProc.running = true;
            if (!layoutProc.running)
                layoutProc.running = true;
        }
    }
}
