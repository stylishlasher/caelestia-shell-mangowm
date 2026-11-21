pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    function toLocalFile(p) {
        const s = String(p ?? "");
        return s.startsWith("file://") ? s.slice(7) : s;
    }
    function _children(obj) {
        let out = [];
        try { if (obj && obj.data) out = out.concat(obj.data); } catch(e) {}
        try { if (obj && obj.children) out = out.concat(obj.children); } catch(e) {}
        try { if (obj && obj.contentItem && obj.contentItem.children) out = out.concat(obj.contentItem.children); } catch(e) {}
        return out;
    }
    function findChild(obj, name) {
        if (!obj || !name) return null;
        const ch = _children(obj);
        for (let i=0; i<ch.length; i++) {
            const c = ch[i]; if (!c) continue;
            try { if (String(c.objectName||"") === name) return c; } catch(e) {}
            const r = findChild(c, name);
            if (r) return r;
        }
        return null;
    }
    function findChildren(obj, name) {
        let out = [];
        if (!obj || !name) return out;
        const ch = _children(obj);
        for (let i=0; i<ch.length; i++) {
            const c = ch[i]; if (!c) continue;
            try { if (String(c.objectName||"") === name) out.push(c); } catch(e) {}
            out = out.concat(findChildren(c, name));
        }
        return out;
    }
    function findChildrenMatching(obj, pattern) {
        let out = [];
        if (!obj) return out;
        let re;
        try { re = new RegExp(pattern); } catch(e) { return out; }
        const ch = _children(obj);
        for (let i=0; i<ch.length; i++) {
            const c = ch[i]; if (!c) continue;
            try { if (re.test(String(c.objectName||""))) out.push(c); } catch(e) {}
            out = out.concat(findChildrenMatching(c, pattern));
        }
        return out;
    }
    function saveItem(item, path, rect, callback) {
        try {
            if (item && item.grabToImage) {
                item.grabToImage(function(result) {
                    try { result.saveToFile(path); } catch(e) { console.log("[CUtils.saveItem]", e); }
                    if (callback) callback();
                });
                return;
            }
        } catch(e) { console.log("[CUtils.saveItem]", e); }
        if (callback) callback();
    }
    function dependency(v) { return v; }
    function clamp(v, lo, hi) { v = Number(v); lo = Number(lo); hi = Number(hi); if (isNaN(v)) return lo; return Math.min(hi, Math.max(lo, v)); }
    function lerp(a,b,t){ return a + (b-a)*t; }
    function mapToItem(from, to, x, y) { try { return from.mapToItem(to, x, y); } catch(e) { return Qt.point(0,0); } }
    function enumToString(obj, prop) {
        try { const v = obj[prop]; return v === undefined || v === null ? "" : String(v); } catch(e) { return ""; }
    }
    function enumToString2(obj, prop) { return enumToString(obj, prop); }
    function copyFile(src, dst) {
        try { Quickshell.execDetached(["sh","-c","cp -- \"$1\" \"$2\"", "sh", String(src), String(dst)]); } catch(e) {}
    }
}
