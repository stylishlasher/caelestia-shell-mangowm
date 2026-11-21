pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME") || ""
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config")

    function expand(path) {
        if (!path)
            return "";
        return String(path).replace(/^~/, root.home);
    }

    function alpha(color, a) {
        return Qt.rgba(color.r, color.g, color.b, a);
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t,
                       a.a + (b.a - a.a) * t);
    }

    function run(command) {
        Quickshell.execDetached(["bash", "-c", command]);
    }

    function launch(command) {
        if (command && command.length > 0)
            Quickshell.execDetached(command);
    }

    function shq(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'";
    }

    function pad(number) {
        return (number < 10 ? "0" : "") + number;
    }

    function clockText(date, use24h, seconds) {
        let text;
        if (use24h)
            text = pad(date.getHours()) + ":" + pad(date.getMinutes());
        else {
            let h = date.getHours() % 12;
            if (h === 0)
                h = 12;
            text = h + ":" + pad(date.getMinutes()) + (date.getHours() >= 12 ? " PM" : " AM");
        }
        if (seconds)
            text += ":" + pad(date.getSeconds());
        return text;
    }

    function dateText(date) {
        const days = ["вс", "пн", "вт", "ср", "чт", "пт", "сб"];
        const months = ["янв", "фев", "мар", "апр", "мая", "июн",
                        "июл", "авг", "сен", "окт", "ноя", "дек"];
        return days[date.getDay()] + ", " + date.getDate() + " " + months[date.getMonth()];
    }

    function layoutLabel(layout) {
        const value = String(layout || "").toLowerCase();
        if (value === "us" || value === "en")
            return "EN";
        if (value === "ru")
            return "RU";
        return value.length > 0 ? value.toUpperCase().slice(0, 2) : "--";
    }

    function weatherIcon(code, isDay) {
        code = Number(code);
        if (code === 0 || code === 1)
            return isDay === false ? "\uf186" : "\uf185";
        if (code === 2)
            return "\uf185";
        if (code === 3)
            return "\uf0c2";
        if (code === 45 || code === 48)
            return "\uf0c2";
        if (code >= 51 && code <= 57)
            return "\uf043";
        if (code >= 61 && code <= 67)
            return "\uf043";
        if (code >= 71 && code <= 77)
            return "\uf2dc";
        if (code >= 80 && code <= 82)
            return "\uf043";
        if (code === 85 || code === 86)
            return "\uf2dc";
        if (code >= 95)
            return "\uf0e7";
        return "\uf0c2";
    }

    function weatherText(code) {
        code = Number(code);
        if (code === 0)
            return "Ясно";
        if (code === 1)
            return "Почти ясно";
        if (code === 2)
            return "Переменная облачность";
        if (code === 3)
            return "Облачно";
        if (code === 45 || code === 48)
            return "Туман";
        if (code >= 51 && code <= 57)
            return "Морось";
        if (code >= 61 && code <= 67)
            return "Дождь";
        if (code >= 71 && code <= 77)
            return "Снег";
        if (code >= 80 && code <= 82)
            return "Ливень";
        if (code === 85 || code === 86)
            return "Снегопад";
        if (code >= 95)
            return "Гроза";
        return "Погода";
    }

    function windDir(deg) {
        deg = Number(deg || 0);
        const dirs = ["С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"];
        return dirs[Math.round(deg / 45) % 8];
    }

    function weekdayShort(index) {
        return ["вс", "пн", "вт", "ср", "чт", "пт", "сб"][index % 7];
    }

    function cleanColor(c) {
        if (!c)
            return "#cba6f7";
        return String(c).trim();
    }
}
