import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"

PanelWindow {
    id: root

    property bool panelOpen: false
    property bool closeOnOutsideClick: true

    color: "transparent"
    focusable: panelOpen
    visible: panelOpen
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay

    Shortcut {
        sequence: "Escape"
        enabled: root.panelOpen
        onActivated: Ui.close()
    }
}
