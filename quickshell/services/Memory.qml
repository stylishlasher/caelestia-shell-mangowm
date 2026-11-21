pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: root
    property real percentage: 0
    property real used: 0
    property real total: 1
    property real free: 0
    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: proc.running = true
    }
    Process {
        id: proc
        command: ["sh","-c","free -k | awk '/Mem:/ {print $2,$7,$3}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p=text.trim().split(/\s+/).map(Number);
                if(p.length>=3){ root.total=p[0]||1; root.free=p[1]||0; root.used=p[2]||Math.max(0,root.total-root.free); root.percentage=root.total>0?root.used/root.total:0; }
            }
        }
    }
}
