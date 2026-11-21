import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "singletons"
import "components"
import "panels"

ShellRoot {
    id: shell

    function screenTarget() {
        if (Mango.focusedName.length > 0)
            return Mango.focusedName;
        if (Quickshell.screens.length > 0)
            return Quickshell.screens[0].name;
        return "";
    }

    function clampVolume(value) {
        return Math.max(0, Math.min(1.5, value));
    }

    function changeVolume(step) {
        const sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio)
            return;
        sink.audio.volume = shell.clampVolume(sink.audio.volume + step);
        if (sink.audio.volume > 0.001)
            sink.audio.muted = false;
        Ui.showOsd("volume", sink.audio.volume * 100, sink.audio.muted);
    }

    function reloadShell() {
        Quickshell.reload(false);
    }

    // Bar -------------------------------------------------------------------
    Variants {
        model: Quickshell.screens

        Bar {
            modelData: modelData
        }
    }

    // Dock ------------------------------------------------------------------
    Variants {
        model: Quickshell.screens

        Dock {
            modelData: modelData
        }
    }

    // Desktop widgets -------------------------------------------------------
    Variants {
        model: Quickshell.screens

        DesktopWidgets {
            modelData: modelData
        }
    }

    // Desktop double-right-click is handled in DesktopWidgets; keep a tiny top-right trigger as fallback.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: "transparent"
            focusable: false
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            implicitWidth: 24
            implicitHeight: 24
            anchors { top: true; right: true }
            margins { top: Theme.barHeight + 4; right: 4 }
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "stylish-desktop-edit-trigger"

            Timer { id: rightClickTimer; interval: 350 }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (rightClickTimer.running) {
                        rightClickTimer.stop();
                        Ui.open("settings", modelData ? String(modelData.name) : shell.screenTarget());
                        Ui.desktopEditRequest++;
                    } else {
                        rightClickTimer.restart();
                    }
                }
            }
        }
    }

    // Top hover dashboard trigger -------------------------------------------
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: Settings.data.barEnabled
            color: "transparent"
            focusable: false
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            implicitHeight: 6
            anchors { top: true; left: true; right: true }
            margins { left: 200; right: 200 }
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "stylish-dashboard-trigger"

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: Ui.open("dashboard", modelData ? String(modelData.name) : "")
                onExited: closeTimer.restart()
            }
            Timer { id: closeTimer; interval: 500; onTriggered: { if (Ui.panel === "dashboard") Ui.close(); } }
        }
    }

    // Wallpaper transition overlay ------------------------------------------
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wpOverlay
            required property var modelData
            screen: modelData
            visible: Ui.wallpaperTransition > 0.01
            color: Utils.alpha(Theme.bg, Ui.wallpaperTransition * 0.85)
            focusable: false
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            anchors { top: true; bottom: true; left: true; right: true }
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "stylish-wallpaper-transition"

            Image {
                anchors.fill: parent
                source: Ui.wallpaperTransitionImage.length > 0 ? "file://" + Ui.wallpaperTransitionImage : ""
                fillMode: Image.PreserveAspectCrop
                opacity: Ui.wallpaperTransition
                asynchronous: true
            }
        }
    }

    // Drop-down panels ------------------------------------------------------
    Variants {
        model: Quickshell.screens

        LauncherPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        SettingsPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        NetworkPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        ClipboardPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        VolumePanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        ControlCenterPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        MusicPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        WallpaperPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        TimeWeatherPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        PowerPanel {
            modelData: modelData
        }
    }

    // Popups and OSD --------------------------------------------------------

    Variants {
        model: Quickshell.screens

        NotificationPopups {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        DashboardPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        NotificationPanel {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        Osd {
            modelData: modelData
        }
    }

    // Lock ------------------------------------------------------------------
    WlSessionLock {
        id: lock
        locked: Ui.locked

        surface: Component {
            LockScreen {}
        }
    }

    // IPC -------------------------------------------------------------------
    IpcHandler {
        target: "shell"

        function toggle(name: string): void {
            Ui.toggle(name, shell.screenTarget());
        }

        function open(name: string): void {
            Ui.open(name, shell.screenTarget());
        }

        function close(): void {
            Ui.close();
        }

        function reload(): void {
            shell.reloadShell();
        }

        function volume(action: string): void {
            const sink = Pipewire.defaultAudioSink;
            if (!sink || !sink.audio)
                return;
            if (action === "up") {
                shell.changeVolume(0.05);
            } else if (action === "down") {
                shell.changeVolume(-0.05);
            } else if (action === "mute") {
                sink.audio.muted = !sink.audio.muted;
                Ui.showOsd("volume", sink.audio.volume * 100, sink.audio.muted);
            } else if (action.indexOf("set:") === 0) {
                const value = parseFloat(action.slice(4));
                if (!isNaN(value)) {
                    sink.audio.volume = shell.clampVolume(value / 100);
                    sink.audio.muted = false;
                    Ui.showOsd("volume", sink.audio.volume * 100, false);
                }
            }
        }

        function mic(): void {
            const source = Pipewire.defaultAudioSource;
            if (!source || !source.audio)
                return;
            source.audio.muted = !source.audio.muted;
            Ui.showOsd("mic", source.audio.volume * 100, source.audio.muted);
        }

        function brightness(action: string): void {
            if (action === "up") {
                Brightness.up(5);
            } else if (action === "down") {
                Brightness.down(5);
            } else if (action.indexOf("set:") === 0) {
                const value = parseFloat(action.slice(4));
                if (!isNaN(value))
                    Brightness.setLevel(value);
            }
            Ui.showOsd("brightness", Brightness.level, false);
        }

        function osd(kind: string, percent: int): void {
            Ui.showOsd(kind, percent, false);
        }

        function lockScreen(): void {
            Ui.close();
            Ui.lock();
        }

        function wallpaper(): void {
            Ui.toggle("wallpaper", shell.screenTarget());
        }

        function power(): void {
            Ui.toggle("power", shell.screenTarget());
        }
    }

    Component.onCompleted: Brightness.refresh()
}
