pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    signal toasted(string title, string message, string icon)
    function toast(title, message, icon) {
        const t = String(title ?? "");
        const m = String(message ?? "");
        const i = String(icon ?? "");
        console.log("[toast]", t, m, i);
        toasted(t, m, i);
    }
}
