pragma Singleton
import Quickshell
import Quickshell.Io
Singleton {
    id: root
    property string osPrettyName: "Linux"
    property string osLogo: "linux"
    property string hostname: "host"
    property string username: "user"
    Process { id: p; command: ["sh","-c",". /etc/os-release 2>/dev/null; echo \"${PRETTY_NAME:-Linux}\"; echo \"${ID:-linux}\"; hostname; whoami"]; running: true
        stdout: StdioCollector { onStreamFinished: { const l=text.trim().split("\n"); root.osPrettyName=l[0]||root.osPrettyName; root.osLogo=l[1]||root.osLogo; root.hostname=l[2]||root.hostname; root.username=l[3]||root.username; } }
    }
}
