pragma Singleton

import QtQuick
import Quickshell
import Caelestia
import Caelestia.State
import qs.components
import qs.services

Singleton {
    id: root

    property ShellRoot shellRoot

    function anySidebarOpen(): bool {
        return states.instances.some(s => s.sidebar)
    }

    function forScreen(screen: var): ScreenState {
        for (let i = 0; i < states.instances.length; i++) {
            const s = states.instances[i];
            if (s.modelData === screen)
                return s;
        }
        return states.instances.length > 0 ? states.instances[0] : null;
    }

    function forActive(): ScreenState {
        try {
            const mon = Hypr.focusedMonitor;
            for (let i = 0; i < states.instances.length; i++) {
                const s = states.instances[i];
                if (Hypr.monitorFor(s.modelData) === mon)
                    return s;
            }
        } catch (e) {}
        return states.instances.length > 0 ? states.instances[0] : null;
    }

    function componentsFor(screen: var): Components {
        for (let i = 0; i < components.instances.length; i++) {
            const c = components.instances[i];
            if (c.modelData === screen)
                return c;
        }
        return null;
    }

    function componentsForActive(): Components {
        try {
            const mon = Hypr.focusedMonitor;
            for (let i = 0; i < components.instances.length; i++) {
                const c = components.instances[i];
                if (Hypr.monitorFor(c.modelData) === mon)
                    return c;
            }
        } catch (e) {}
        return null;
    }

    Variants {
        id: states
        model: Screens.screens
        ScreenState {}
    }

    Variants {
        id: components
        model: Screens.screens
        Components {}
    }

    component Components: QtObject {
        required property var modelData
        property var background
        property var rootWindow
        property var interactionWrapper
        property var bar
        property var panels

        function find(name: string, rootItem: Item): var {
            try { return CUtils.findChild(rootItem ?? rootWindow?.contentItem, name); } catch (e) { return null; }
        }
        function findAll(name: string, rootItem: Item): var {
            try { return CUtils.findChildren(rootItem ?? rootWindow?.contentItem, name); } catch (e) { return []; }
        }
        function findMatching(pattern: string, rootItem: Item): var {
            try { return CUtils.findChildrenMatching(rootItem ?? rootWindow?.contentItem, pattern); } catch (e) { return []; }
        }
    }

    component ComponentRef: QtObject {
        required property var screen
        required property string slot
        required property var component
        readonly property QtObject target: ShellState.componentsFor(screen)
        onTargetChanged: { if (target) target[slot] = component; }
        Component.onDestruction: { if (target && target[slot] === component) target[slot] = null; }
    }
}
