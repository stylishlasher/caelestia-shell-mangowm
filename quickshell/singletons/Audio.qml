pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property PwNode source: Pipewire.ready ? Pipewire.defaultAudioSource : null

    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool sourceMuted: !!source?.audio?.muted
    readonly property real sourceVolume: source?.audio?.volume ?? 0

    readonly property var sinks: {
        const list = [];
        const nodes = Pipewire.nodes?.values ?? [];
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (n && !n.isStream && n.isSink && n.audio)
                list.push(n);
        }
        return list;
    }

    readonly property var sources: {
        const list = [];
        const nodes = Pipewire.nodes?.values ?? [];
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (n && !n.isStream && !n.isSink && n.audio)
                list.push(n);
        }
        return list;
    }

    readonly property var streams: {
        const list = [];
        const nodes = Pipewire.nodes?.values ?? [];
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (n && n.isStream && n.audio)
                list.push(n);
        }
        return list;
    }

    function clampVolume(v) {
        return Math.max(0, Math.min(1.5, v));
    }

    function setVolume(v) {
        if (sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = clampVolume(v);
        }
    }

    function setSourceVolume(v) {
        if (source?.audio) {
            source.audio.muted = false;
            source.audio.volume = clampVolume(v);
        }
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function toggleSourceMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    function setDefaultSink(node) {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node) {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    function setStreamVolume(node, v) {
        if (node?.audio) {
            node.audio.muted = false;
            node.audio.volume = clampVolume(v);
        }
    }

    function toggleStreamMute(node) {
        if (node?.audio)
            node.audio.muted = !node.audio.muted;
    }

    function nodeName(node) {
        if (!node) return "";
        return node.description || node.nickname || node.name || "Unknown";
    }

    function appName(node) {
        if (!node) return "App";
        return node.properties?.["application.name"]
            || node.properties?.["media.name"]
            || node.description
            || node.name
            || "App";
    }

    PwObjectTracker {
        objects: [root.sink, root.source, ...root.sinks, ...root.sources, ...root.streams].filter(n => n)
    }
}
