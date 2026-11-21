pragma Singleton

import Quickshell
import Caelestia.Config

Singleton {
    id: root

    readonly property list<var> screens: {
        const all = Quickshell.screens || [];
        console.log("[Screens] all=", all.length);
        const out = all.filter(s => { try { return GlobalConfig.forScreen(s.name).enabled !== false; } catch(e){ return true; } });
        console.log("[Screens] filtered=", out.length);
        return out;
    }

    function isExcluded(screen: var): bool {
        return !GlobalConfig.forScreen(screen.name).enabled;
    }
}
