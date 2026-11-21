pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var moduleDefs: ({
        "launcher": { label: "Лаунчер", icon: "\uf0c9" },
        "workspaces": { label: "Воркспейсы", icon: "\uf009" },
        "window": { label: "Окно", icon: "\uf2d0" },
        "media": { label: "Медиа", icon: "\uf001" },
        "network": { label: "Сеть", icon: "\uf1eb" },
        "bluetooth": { label: "Bluetooth", icon: "\uf294" },
        "volume": { label: "Громкость", icon: "\uf028" },
        "battery": { label: "Батарея", icon: "\uf240" },
        "clock": { label: "Часы", icon: "\uf017" },
        "notifications": { label: "Уведомления", icon: "\uf0f3" },
        "power": { label: "Питание", icon: "\uf011" }
    })

    readonly property var defaults: ({
        left: ["launcher", "workspaces", "window"],
        center: ["media", "clock"],
        right: ["network", "bluetooth", "volume", "battery", "notifications", "power"]
    })

    function list(section) {
        const key = section === "left" ? "barLeftModules" : section === "center" ? "barCenterModules" : "barRightModules";
        const v = Settings.data[key];
        if (v && v.length !== undefined && v.length > 0)
            return v.slice();
        return (root.defaults[section] || []).slice();
    }

    function setList(section, arr) {
        const key = section === "left" ? "barLeftModules" : section === "center" ? "barCenterModules" : "barRightModules";
        Settings.data[key] = arr;
    }

    function has(section, id) {
        return list(section).indexOf(id) !== -1;
    }

    function toggle(section, id) {
        const arr = list(section);
        const i = arr.indexOf(id);
        if (i === -1) arr.push(id);
        else arr.splice(i, 1);
        setList(section, arr);
    }

    function move(section, id, delta) {
        const arr = list(section);
        const i = arr.indexOf(id);
        if (i === -1) return;
        const j = Math.max(0, Math.min(arr.length - 1, i + delta));
        if (i === j) return;
        const tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
        setList(section, arr);
    }
}
