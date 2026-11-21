pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Wrap Quickshell's desktop entry database.
    readonly property var applications: Quickshell.DesktopEntries.applications

    function byId(id) {
        if (!id)
            return null;
        return Quickshell.DesktopEntries.byId(String(id));
    }

    function heuristicLookup(id) {
        if (!id)
            return null;
        try {
            return Quickshell.DesktopEntries.heuristicLookup(String(id));
        } catch (e) {
            return root.byId(id);
        }
    }
}
