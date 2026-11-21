import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: win
    required property string name

    WlrLayershell.namespace: `caelestia-${name}`
    color: "transparent"
}
