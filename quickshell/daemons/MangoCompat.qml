pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.State
import qs.services

Scope {
    id: root

    function screenState() {
        try { return ShellState.forActive(); } catch (e) { return null; }
    }

    function togglePanel(name: string): void {
        const st = screenState();
        if (!st) return;
        const map = {
            launcher: "launcher",
            dashboard: "dashboard",
            session: "session",
            sidebar: "sidebar",
            utilities: "utilities",
            osd: "osd",
            bar: "bar",
            settings: "dashboard",
            network: "dashboard",
            clipboard: "launcher",
            volume: "dashboard",
            control: "dashboard",
            music: "dashboard",
            wallpaper: "dashboard",
            time: "dashboard",
            power: "session",
            notifications: "sidebar"
        };
        const drawer = map[name] || name;
        if (typeof st[drawer] === "boolean")
            st[drawer] = !st[drawer];
    }

    function openPanel(name: string): void {
        const st = screenState();
        if (!st) return;
        const map = { power: "session", settings: "dashboard", wallpaper: "dashboard" };
        const drawer = map[name] || name;
        if (typeof st[drawer] === "boolean")
            st[drawer] = true;
    }

    function closePanels(): void {
        const st = screenState();
        if (!st) return;
        ["launcher","dashboard","session","sidebar","utilities","osd"].forEach(k => { if (typeof st[k] === "boolean") st[k] = false; });
    }

    IpcHandler {
        target: "shell"

        function toggle(name: string): void { root.togglePanel(name); }
        function open(name: string): void { root.openPanel(name); }
        function close(): void { root.closePanels(); }
        function reload(): void { Quickshell.reload(true); }
        function lockScreen(): void { root.closePanels(); try { Quickshell.execDetached(["qs","ipc","call","lock","lock"]); } catch(e) {} }
        function wallpaper(): void { root.openPanel("wallpaper"); }
        function power(): void { root.togglePanel("power"); }
        function volume(action: string): void {
            try {
                if (action === "up") Audio.incrementVolume();
                else if (action === "down") Audio.decrementVolume();
                else if (action === "mute") Audio.setVolume(Audio.muted ? 0.5 : 0);
                else if (action.startsWith("set:")) Audio.setVolume(parseFloat(action.slice(4)) / 100);
            } catch (e) { console.log("volume ipc compat err", e); }
        }
        function mic(): void { try { Audio.setSourceVolume(Audio.sourceMuted ? 0.5 : 0); } catch(e){} }
        function brightness(action: string): void {
            try {
                if (action === "up") Brightness.increaseBrightness();
                else if (action === "down") Brightness.decreaseBrightness();
            } catch (e) {}
        }
        function osd(kind: string, percent: int): void { console.log("osd compat", kind, percent); }
    }
}
