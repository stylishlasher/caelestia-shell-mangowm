pragma Singleton
import QtQuick
import Quickshell

Singleton {
    function tr(s) { return String(s ?? ""); }
    function trCtx(ctx, s) { return String(s ?? ""); }
    function formatDateTime(date, fmt) {
        try { return Qt.formatDateTime(date, String(fmt || "")); } catch(e) { try { return String(date); } catch(e2) { return ""; } }
    }
}
