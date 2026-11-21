pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var fileColors: ({})
    property var fileColorsLight: ({})

    readonly property bool useMatugen: Settings.data.useMatugen
        && ((Settings.data.matugenColors && Settings.data.matugenColors.primary !== undefined)
            || (fileColors && fileColors.primary !== undefined))
    readonly property bool isDark: Settings.data.themeMode !== "light"

    function palette(key, fallback) {
        const dark = (Settings.data.matugenColors && Settings.data.matugenColors.primary !== undefined)
            ? Settings.data.matugenColors : root.fileColors;
        const light = (Settings.data.matugenColorsLight && Settings.data.matugenColorsLight.primary !== undefined)
            ? Settings.data.matugenColorsLight
            : (root.fileColorsLight && root.fileColorsLight.primary !== undefined ? root.fileColorsLight : dark);
        const colors = root.isDark ? dark : light;
        if (colors && colors[key] !== undefined && colors[key] !== null && colors[key] !== "")
            return colors[key];
        return fallback;
    }

    FileView {
        path: Utils.configHome + "/stylish/matugen-colors.json"
        watchChanges: true
        printErrors: false
        onLoaded: { try { root.fileColors = JSON.parse(text()); } catch (e) {} }
    }

    FileView {
        path: Utils.configHome + "/stylish/matugen-colors-light.json"
        watchChanges: true
        printErrors: false
        onLoaded: { try { root.fileColorsLight = JSON.parse(text()); } catch (e) {} }
    }

    // Core palette -----------------------------------------------------------
    readonly property color bg: useMatugen
        ? palette("background", isDark ? "#0e0c13" : "#f5f2fa")
        : (isDark ? "#0e0c13" : "#f5f2fa")
    readonly property color bgLow: useMatugen
        ? palette("surface_container_low", isDark ? "#100d17" : "#faf8fd")
        : (isDark ? "#100d17" : "#faf8fd")
    readonly property color surface: useMatugen
        ? palette("surface_container", isDark ? "#17131f" : "#ffffff")
        : (isDark ? "#17131f" : "#ffffff")
    readonly property color surfaceHigh: useMatugen
        ? palette("surface_container_high", isDark ? "#211b2c" : "#eee9f6")
        : (isDark ? "#211b2c" : "#eee9f6")
    readonly property color surfaceHighest: useMatugen
        ? palette("surface_container_highest", isDark ? "#2a2336" : "#e7e0f1")
        : (isDark ? "#2a2336" : "#e7e0f1")
    readonly property color text: useMatugen
        ? palette("on_surface", isDark ? "#ece7f4" : "#211c2b")
        : (isDark ? "#ece7f4" : "#211c2b")
    readonly property color subtext: useMatugen
        ? palette("on_surface_variant", isDark ? "#aaa1bb" : "#6a6279")
        : (isDark ? "#aaa1bb" : "#6a6279")
    readonly property color border: useMatugen
        ? palette("outline_variant", isDark ? "#2f283d" : "#ded6ec")
        : (isDark ? "#2f283d" : "#ded6ec")
    readonly property color outline: useMatugen
        ? palette("outline", isDark ? "#716785" : "#847a95")
        : (isDark ? "#716785" : "#847a95")

    readonly property color accent: useMatugen
        ? palette("primary", Settings.data.accent)
        : Settings.data.accent
    readonly property color onAccent: useMatugen
        ? palette("on_primary", isDark ? "#241333" : "#ffffff")
        : (isDark ? "#241333" : "#ffffff")
    readonly property color accentSoft: useMatugen
        ? palette("primary_container", isDark ? "#3c2455" : "#ecdcff")
        : (isDark ? "#3c2455" : "#ecdcff")
    readonly property color onAccentSoft: useMatugen
        ? palette("on_primary_container", isDark ? "#f0dbff" : "#281043")
        : (isDark ? "#f0dbff" : "#281043")
    readonly property color secondary: useMatugen
        ? palette("tertiary", isDark ? "#f3b7bd" : "#805157")
        : (isDark ? "#f3b7bd" : "#805157")
    readonly property color secondarySoft: useMatugen
        ? palette("secondary_container", isDark ? "#4d4356" : "#edddf6")
        : (isDark ? "#4d4356" : "#edddf6")

    readonly property color red: useMatugen
        ? palette("error", isDark ? "#ffb4ab" : "#ba1a1a")
        : (isDark ? "#ffb4ab" : "#ba1a1a")
    readonly property color green: isDark ? "#a6e3a1" : "#2e7d4f"
    readonly property color yellow: isDark ? "#f9e2af" : "#8a6300"
    readonly property color blue: isDark ? "#89b4fa" : "#2762b8"

    // Surfaces ---------------------------------------------------------------
    readonly property color barColor: Utils.alpha(surface, Settings.data.barOpacity)
    readonly property color panelColor: Utils.alpha(surface, Settings.data.panelOpacity)
    readonly property color dockColor: Utils.alpha(surfaceHigh, Settings.data.barOpacity)
    readonly property color hover: Utils.alpha(text, isDark ? 0.07 : 0.06)
    readonly property color pressed: Utils.alpha(text, isDark ? 0.12 : 0.10)
    readonly property color shadow: Qt.rgba(0, 0, 0, isDark ? 0.45 : 0.18)

    // Geometry ---------------------------------------------------------------
    readonly property int radius: Settings.data.cornerRadius
    readonly property int radiusSmall: Math.max(8, Math.round(Settings.data.cornerRadius * 0.55))
    readonly property int barHeight: Settings.data.barHeight
    readonly property int dockHeight: Settings.data.dockIconSize + 22
    readonly property int spacing: 8

    // Typography -------------------------------------------------------------
    readonly property string font: "Google Sans"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontSmall: 11
    readonly property int fontTiny: 10
    readonly property int fontLarge: 20

    // Motion -----------------------------------------------------------------
    readonly property int durationFast: 120
    readonly property int duration: 180
    readonly property int durationSlow: 320
    readonly property int easing: Easing.OutCubic
}
