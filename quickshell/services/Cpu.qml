pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: root
    property real percentage: 0
    property real temperature: 0
    property string name: "CPU"
    property var percents: []
    Process {
        id: cpuProc
        running: true
        command: ["sh","-c","grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //' || echo CPU"]
        stdout: StdioCollector { onStreamFinished: { const t=text.trim(); if(t) root.name=t; } }
    }
    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: statProc.running = true
    }
    property var _prev: null
    Process {
        id: statProc
        command: ["sh","-c","head -n1 /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(/\s+/).slice(1).map(Number);
                if (p.length < 4) return;
                const idle = (p[3]||0) + (p[4]||0);
                const total = p.reduce((a,b)=>a+b,0);
                if (root._prev) {
                    const dt = total-root._prev.total; const di = idle-root._prev.idle;
                    if (dt>0) root.percentage = Math.max(0, Math.min(1, 1-di/dt));
                }
                root._prev = {total,idle};
            }
        }
    }
}
