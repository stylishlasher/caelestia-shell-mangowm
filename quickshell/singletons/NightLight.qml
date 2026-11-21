pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available: true
    property bool enabled: Settings.data.nightLightEnabled
    property int temperature: Settings.data.nightLightTemp

    function apply() {
        stopProc.running = false;
        stopProc.command = ["bash", "-c", "pkill -x wlsunset gammastep 2>/dev/null || true"];
        stopProc.running = true;
        if (root.enabled)
            startTimer.restart();
    }

    function setEnabled(value) {
        Settings.data.nightLightEnabled = value;
        root.enabled = value;
        apply();
    }

    function setTemperature(value) {
        const v = Math.max(2500, Math.min(6500, Math.round(value)));
        Settings.data.nightLightTemp = v;
        root.temperature = v;
        if (root.enabled)
            apply();
    }

    Process { id: stopProc; running: false }

    Process {
        id: startProc
        running: false
    }

    Timer {
        id: startTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!root.enabled)
                return;
            const t = Math.max(2500, Math.min(6500, root.temperature));
            startProc.command = ["bash", "-c",
                "if command -v wlsunset >/dev/null 2>&1; then exec wlsunset -T 6500 -t " + t + "; "
                + "elif command -v gammastep >/dev/null 2>&1; then exec gammastep -O " + t + "; fi"];
            startProc.running = true;
        }
    }

    Connections {
        target: Settings.data
        function onNightLightEnabledChanged() { root.enabled = Settings.data.nightLightEnabled; root.apply(); }
        function onNightLightTempChanged() { root.temperature = Settings.data.nightLightTemp; if (root.enabled) root.apply(); }
    }

    Component.onCompleted: apply()
}
