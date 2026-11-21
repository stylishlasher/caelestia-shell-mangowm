pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: {
        const list = root.players || [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].isPlaying)
                return list[i];
        }
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].trackTitle)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player && player.trackTitle ? player.trackTitle : ""
    readonly property string artist: {
        if (!player)
            return "";
        if (player.trackArtists && player.trackArtists.length > 0)
            return player.trackArtists;
        return player.trackArtist || "";
    }
    readonly property string album: player && player.trackAlbum ? player.trackAlbum : ""
    readonly property string identity: player && player.identity ? player.identity : ""
    readonly property string desktopEntry: player && player.desktopEntry ? player.desktopEntry : ""

    readonly property string artUrl: {
        if (!player || !player.trackArtUrl)
            return "";
        const url = String(player.trackArtUrl);
        if (url.startsWith("file://") || url.startsWith("http://") || url.startsWith("https://") || url.startsWith("image://"))
            return url;
        return "file://" + url;
    }

    readonly property real length: player ? (player.length || 0) : 0

    // Ticks so time-dependent bindings (progress, lyrics) refresh regularly.
    property int tick: 0
    Timer {
        interval: 500
        repeat: true
        running: root.playing
        onTriggered: root.tick++
    }

    function position() {
        return root.player ? (root.player.position || 0) : 0;
    }

    function toggle() {
        if (root.player)
            root.player.togglePlaying();
    }

    function next() {
        if (root.player)
            root.player.next();
    }

    function previous() {
        if (root.player)
            root.player.previous();
    }

    function seek(offset) {
        if (root.player && root.player.canSeek)
            root.player.seek(offset);
    }

    function seekTo(seconds) {
        if (!root.player)
            return;
        const delta = seconds - (root.player.position || 0);
        if (root.player.canSeek)
            root.player.seek(delta);
    }

    function formatTime(seconds) {
        seconds = Math.max(0, Math.floor(Number(seconds) || 0));
        const minutes = Math.floor(seconds / 60);
        const rest = seconds % 60;
        return minutes + ":" + (rest < 10 ? "0" : "") + rest;
    }
}
