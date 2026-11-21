pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int level: 0
    property bool available: false
    property bool busy: false
    property string device: ""

    function clamp(value) {
        return Math.max(1, Math.min(100, Math.round(Number(value) || 0)));
    }

    function refresh() {
        if (readProcess.running)
            return;
        readProcess.running = true;
    }

    function setLevel(value) {
        const next = root.clamp(value);
        root.level = next;
        Utils.run("if command -v brightnessctl >/dev/null 2>&1; then "
            + "brightnessctl set " + next + "%; else "
            + "max=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | head -n1); "
            + "cur=$((max * " + next + " / 100)); "
            + "for f in /sys/class/backlight/*/brightness; do echo $cur > \"$f\" 2>/dev/null; break; done; fi");
    }

    function up(step) {
        root.setLevel(root.level + (step === undefined ? 5 : step));
    }

    function down(step) {
        root.setLevel(root.level - (step === undefined ? 5 : step));
    }

    function toggle() {
        root.setLevel(root.level > 0 ? 0 : 60);
    }

    Process {
        id: readProcess
        running: false
        command: ["bash", "-c",
            "if command -v brightnessctl >/dev/null 2>&1; then "
            + "cur=$(brightnessctl get 2>/dev/null); max=$(brightnessctl max 2>/dev/null); "
            + "[ -n \"$cur\" ] && [ -n \"$max\" ] && [ \"$max\" -gt 0 ] && echo $((cur * 100 / max)); "
            + "else "
            + "for f in /sys/class/backlight/*/brightness; do "
            + "[ -e \"$f\" ] || continue; "
            + "cur=$(cat \"$f\"); max=$(cat \"${f%brightness}max_brightness\"); "
            + "[ \"$max\" -gt 0 ] && echo $((cur * 100 / max)); break; "
            + "done; fi"]

        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(String(data).trim());
                if (!isNaN(value)) {
                    root.level = Math.max(0, Math.min(100, value));
                    root.available = true;
                }
            }
        }
    }

    Timer {
        interval: 8000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
