pragma Singleton

import Quickshell
import Caelestia.Config
import qs.utils
import "../../../singletons" as S

Searcher {
    id: root

    readonly property string prefix: Config.launcher.specialPrefix

    function launch(entry) {
        if (!entry) return;
        try {
            if (entry.runInTerminal)
                Quickshell.execDetached({
                    command: [...(Config.general.apps.terminal || ["foot"]), String(entry.execString || entry.command || "")],
                    workingDirectory: entry.workingDirectory || Quickshell.env("HOME")
                });
            else if (entry.execute)
                entry.execute();
            else if (entry.execString)
                Quickshell.execDetached(["sh","-c", String(entry.execString)]);
        } catch(e) { console.log("launch failed", e); }
    }

    function search(search) {
        const q = String(search || "");
        const list = S.DesktopEntries.entries || [];
        if (!q) return list;
        const lq = q.toLowerCase();
        return list.filter(e => String(e.name||"").toLowerCase().includes(lq) || String(e.genericName||"").toLowerCase().includes(lq) || String(e.comment||"").toLowerCase().includes(lq));
    }

    function selector(item) { return String(item?.name || ""); }

    list: S.DesktopEntries.entries
    useFuzzy: Config.launcher.useFuzzy.apps
}
