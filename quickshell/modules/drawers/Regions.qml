pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.modules.bar as Bar

Region {
    id: root

    required property Bar.BarWrapper bar
    required property Panels panels
    required property var win

    readonly property real borderThickness: Config.border.thickness
    readonly property real clampedThickness: Math.max(Config.border.thickness, 1)

    x: bar.clampedWidth + win.dragMaskPadding
    y: clampedThickness + win.dragMaskPadding
    width: win.width - bar.clampedWidth - clampedThickness - win.dragMaskPadding * 2
    height: win.height - clampedThickness * 2 - win.dragMaskPadding * 2
    intersection: Intersection.Xor

    R {
        panel: root.panels.dashboard
        y: 0
        height: Math.max(0, (panel?.height ?? 0) * (1 - (root.panels.dashboard?.offsetScale ?? 1))) + root.borderThickness
    }

    R {
        panel: root.panels.launcher
        y: root.win.height - height
        height: Math.max(0, (panel?.height ?? 0) * (1 - (root.panels.launcher?.offsetScale ?? 1))) + root.borderThickness
    }

    R {
        id: sessionRegion

        panel: root.panels.sessionWrapper
        x: root.win.width - width
        width: Math.max(0, (panel?.width ?? 0) * (1 - (root.panels.session?.offsetScale ?? 1))) + root.borderThickness + sidebarRegion.width
    }

    R {
        id: sidebarRegion

        panel: root.panels.sidebar
        x: root.win.width - width
        width: Math.max(0, (panel?.width ?? 0) * (1 - (root.panels.sidebar?.offsetScale ?? 1))) + root.borderThickness
    }

    R {
        panel: root.panels.osdWrapper
        x: root.win.width - width
        width: Math.max(0, (panel?.width ?? 0) * (1 - (root.panels.osd?.offsetScale ?? 1))) + root.borderThickness + sessionRegion.width
    }

    R {
        panel: root.panels.notifications
        y: 0
        height: Math.max(0, panel?.height ?? 0) + root.borderThickness
    }

    R {
        panel: root.panels.utilities
        y: root.win.height - height
        height: Math.max(0, (panel?.height ?? 0) * (1 - (root.panels.utilities?.offsetScale ?? 1))) + root.borderThickness
    }

    R {
        panel: root.panels.popoutsWrapper
        width: Math.max(0, (panel?.width ?? 0) * (1 - (root.panels.popoutsWrapper?.offsetScale ?? 1)))
    }

    component R: Region {
        required property Item panel

        x: (panel?.x ?? 0) + root.bar.implicitWidth
        y: (panel?.y ?? 0) + root.borderThickness
        width: Math.max(0, panel?.width ?? 0)
        height: Math.max(0, panel?.height ?? 0)
        intersection: Intersection.Subtract
    }
}
