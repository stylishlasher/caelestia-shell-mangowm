pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../singletons" as S

Singleton {
    id: root

    property string screen: ""
    function forScreen(name) { return ({ enabled: true, name: name }); }

    // Settings persistence bridge (Caelestia expects Config.*; we back with stylish settings where sensible)
    readonly property string _cfgDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/stylish"
    readonly property string _cfgPath: _cfgDir + "/caelestia-port.json"

    property var appearance: ({
        transparency: ({ enabled: true, base: 0.78, layers: 0.45 }),
        padding: ({ scale: 1 }),
        spacing: ({ scale: 1 }),
        font: ({ size: ({ scale: 1 }), family: ({
            sans: S.Theme.font || "Rubik",
            mono: S.Theme.mono || "JetBrains Mono NF",
            material: "Material Symbols Rounded",
            clock: S.Theme.font || "Rubik"
        }) }),
        rounding: ({ scale: 1 }),
        deformScale: 1,
        anim: ({ durations: ({ scale: 1 }) }),
        background: ({ enabled: true })
    })

    property var general: ({
        logo: "arch",
        showOverFullscreen: false,
        apps: ({
            terminal: ["foot"],
            audio: ["pavucontrol"],
            explorer: ["foot", "-e", "yazi"],
            playback: ["mpv"]
        }),
        idle: ({ timeouts: [] })
    })

    property var background: ({
        enabled: true,
        wallpaperEnabled: true,
        desktopClock: ({ enabled: S.Settings.data.showDesktopClock, position: S.Settings.data.desktopWidgetPosition || "top-right", scale: 1, invertColors: false, background: true, shadow: ({ enabled: true, opacity: 0.7, blur: 0.4 }) }),
        visualiser: ({ enabled: false, autoHide: true, blur: false, rounding: 1, spacing: 1 })
    })

    property var border: ({ thickness: 1, rounding: 20, smoothing: 0 })

    property var services: ({
        audioIncrement: 0.05,
        brightnessIncrement: 0.05,
        maxVolume: 1.5,
        smartScheme: S.Settings.data.useMatugen,
        defaultPlayer: "Spotify",
        playerAliases: [{ from: "com.github.th_ch.youtube_music", to: "YT Music" }],
        weatherLocation: S.Settings.data.weatherCity || "",
        useFahrenheit: [!S.Settings.data.weatherMetric],
        useTwelveHourClock: !S.Settings.data.use24h,
        gpuType: "",
        visualiserBars: 45,
        dataUnits: "kB/s",
        sensorUnits: "celsius",
        clockFormat: S.Settings.data.use24h ? "HH:mm" : "hh:mm ap",
        networkRescanInterval: 60
    })

    property var utilities: ({
        enabled: true,
        maxToasts: 4,
        toasts: ({
            configLoaded: false, chargingChanged: true, gameModeChanged: true, dndChanged: true,
            audioOutputChanged: true, audioInputChanged: true, capsLockChanged: true, numLockChanged: true,
            kbLayoutChanged: true, vpnChanged: true, nowPlaying: false, fullscreen: false
        }),
        vpn: ({ enabled: false, provider: ["netextender"], selectedProvider: 0 }),
        gameMode: ({ options: ({}) })
    })

    property var bar: ({
        enabled: true,
        persistent: true,
        showOnHover: !S.Settings.data.barFloating ? true : false,
        dragThreshold: 20,
        scrollActions: ({ volume: true, brightness: true, workspaces: true }),
        workspaces: ({
            shown: S.Settings.data.tagCount || 5,
            activeIndicator: true, occupiedBg: false, showWindows: true, showWindowsOnSpecialWorkspaces: true,
            activeTrail: false, perMonitorWorkspaces: true, perMonitor: true,
            label: "", occupiedLabel: "", activeLabel: "",
            showUnoccupied: true, displayType: 0, maxWindowIcons: 0,
            specialWorkspaceIcons: [], workspaceIcons: [], ignoredTags: []
        }),
        tray: ({ background: false, recolour: false, compact: false, iconSubs: [], hiddenIcons: [] }),
        activeWindow: ({ showOnHover: true, inverted: false }),
        status: ({ showAudio: false, showMicrophone: false, showKbLayout: false, showNetwork: true, showBluetooth: true, showBattery: true, showLockStatus: true }),
        statusIcons: ({
            values: [
                { id: "lockStatus", enabled: true },
                { id: "audio", enabled: false },
                { id: "microphone", enabled: false },
                { id: "kbLayout", enabled: false },
                { id: "network", enabled: true },
                { id: "bluetooth", enabled: true },
                { id: "battery", enabled: true }
            ]
        }),
        clock: ({ showIcon: false, showDate: false, showSeconds: false, background: false }),
        popouts: ({ activeWindow: true, tray: true, statusIcons: true }),
        entries: ([
            { id: "logo", enabled: true },
            { id: "workspaces", enabled: S.Settings.data.showWorkspaces !== false },
            { id: "spacer", enabled: true },
            { id: "activeWindow", enabled: S.Settings.data.showActiveWindow !== false },
            { id: "spacer", enabled: true },
            { id: "tray", enabled: S.Settings.data.showTray !== false },
            { id: "clock", enabled: S.Settings.data.showClock !== false },
            { id: "statusIcons", enabled: true },
            { id: "power", enabled: S.Settings.data.showPower !== false }
        ])
    })

    property var dashboard: ({ enabled: true, showOnHover: true, dragThreshold: 50, mediaUpdateInterval: 500, resourceUpdateInterval: 3000, showDashboard: true, showMedia: true, showPerformance: true, showWeather: true })
    property var launcher: ({
        enabled: true, showOnHover: false, dragThreshold: 50, vimKeybinds: false, enableDangerousActions: false, maxShown: 7,
        maxWallpapers: 9, favouriteApps: S.Settings.data.pinnedApps || [], hiddenApps: [], actionPrefix: ">", specialPrefix: "@",
        useFuzzy: ({ apps: false, actions: false, schemes: false, variants: false, wallpapers: false }),
        sizes: ({ itemWidth: 600, itemHeight: 57, wallpaperWidth: 280, wallpaperHeight: 200 }),
        actions: [
            { name: "Calculator", icon: "calculate", description: "Do simple math equations (powered by Qalc)", command: ["autocomplete", "calc"], enabled: true, dangerous: false },
            { name: "Scheme", icon: "palette", description: "Change the current colour scheme", command: ["autocomplete", "scheme"], enabled: true, dangerous: false },
            { name: "Wallpaper", icon: "image", description: "Change the current wallpaper", command: ["autocomplete", "wallpaper"], enabled: true, dangerous: false },
            { name: "Variant", icon: "colors", description: "Change the current scheme variant", command: ["autocomplete", "variant"], enabled: true, dangerous: false },
            { name: "Transparency", icon: "opacity", description: "Change shell transparency", command: ["autocomplete", "transparency"], enabled: false, dangerous: false },
            { name: "Random", icon: "casino", description: "Switch to a random wallpaper", command: ["caelestia", "wallpaper", "-r"], enabled: true, dangerous: false },
            { name: "Light", icon: "light_mode", description: "Change the scheme to light mode", command: ["setMode", "light"], enabled: true, dangerous: false },
            { name: "Dark", icon: "dark_mode", description: "Change the scheme to dark mode", command: ["setMode", "dark"], enabled: true, dangerous: false },
            { name: "Shutdown", icon: "power_settings_new", description: "Shutdown the system", command: ["systemctl", "poweroff"], enabled: true, dangerous: true },
            { name: "Reboot", icon: "cached", description: "Reboot the system", command: ["systemctl", "reboot"], enabled: true, dangerous: true },
            { name: "Logout", icon: "exit_to_app", description: "Log out of the current session", command: ["loginctl", "terminate-user", ""], enabled: true, dangerous: true },
            { name: "Lock", icon: "lock", description: "Lock the current session", command: ["loginctl", "lock-session"], enabled: true, dangerous: false },
            { name: "Sleep", icon: "bedtime", description: "Suspend then hibernate", command: ["systemctl", "suspend-then-hibernate"], enabled: true, dangerous: false },
            { name: "Settings", icon: "settings", description: "Configure the shell", command: ["caelestia", "shell", "controlCenter", "open"], enabled: true, dangerous: false }
        ]
    })

    property var notifs: ({ defaultExpireTimeout: 5000, expire: true, fullscreen: false, actionOnClick: false, clearThreshold: 0.3, groupPreviewNum: 3, expandThreshold: 20 })
    property var osd: ({ enabled: S.Settings.data.osdEnabled !== false, hideDelay: 2000, enableBrightness: true, enableMicrophone: false })
    property var session: ({ enabled: true, dragThreshold: 30, vimKeybinds: false, commands: ({ logout: ["loginctl","terminate-user",""], shutdown: ["systemctl","poweroff"], hibernate: ["systemctl","hibernate"], reboot: ["systemctl","reboot"] }) })
    property var sidebar: ({ enabled: true, dragThreshold: 80 })
    property var lock: ({ recolourLogo: false, enableFprint: true, maxFprintTries: 3, maxHowdyTries: 3, maxNotifs: 5, lockBeforeSleep: true, sizes: ({ heightMult: 0.7, ratio: 16/9, centerWidth: 600 }) })
    property var nexus: ({ enabled: true, networkRescanInterval: 60, maxNetworksShown: 8, sizes: ({ heightMult: 0.7, ratio: 16/9, minWidth: 800, minHeight: 500, maxNavWidth: 300, maxContentWidth: 800 }) })
    property var winfo: ({ enabled: true, sizes: ({ heightMult: 0.7, detailsWidth: 500 }) })
    property var paths: ({ wallpaperDir: S.Settings.data.wallpaperDir || "~/Pictures/Wallpapers", sessionGif: "root:/assets/bongocat.gif", mediaGif: "root:/assets/bongocat.gif" })
}
