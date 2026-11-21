import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"
import "../components"

Scope {
    id: dockRoot

    property var modelData: null
    property bool revealed: false
    property bool hovered: false

    readonly property bool autoHide: Settings.data.dockAutoHide
    readonly property bool shown: Settings.data.dockEnabled
        && (!autoHide || revealed)
    readonly property int iconSize: Settings.data.dockIconSize
    readonly property int gap: 6
    readonly property var entries: {
        // Depend on live client state and pinned configuration.
        const clients = Mango.clients || [];
        const pinned = Settings.data.pinnedApps || [];
        const result = [];
        const seen = {};

        for (let i = 0; i < pinned.length; i++) {
            const id = pinned[i];
            const entry = DesktopEntries.byId(id);
            const label = entry ? entry.name : id;
            const icon = entry ? entry.icon : id;
            result.push({
                id: id,
                name: label,
                icon: icon,
                entry: entry,
                clientId: -1,
                running: false,
                active: false
            });
            seen[id] = true;
        }

        for (let i = 0; i < clients.length; i++) {
            const client = clients[i];
            if (!client || !client.appid)
                continue;
            const entry = DesktopEntries.heuristicLookup(client.appid);
            const id = entry ? entry.id : client.appid;
            if (seen[id])
                continue;
            seen[id] = true;
            result.push({
                id: id,
                name: entry ? entry.name : client.appid,
                icon: entry ? entry.icon : client.appid,
                entry: entry,
                clientId: client.id,
                running: true,
                active: client.is_focused === true
            });
        }

        // Mark pinned applications that currently have windows.
        for (let r = 0; r < result.length; r++) {
            if (result[r].clientId >= 0)
                continue;
            for (let c = 0; c < clients.length; c++) {
                const client = clients[c];
                if (!client || !client.appid)
                    continue;
                const entry = DesktopEntries.heuristicLookup(client.appid);
                const id = entry ? entry.id : client.appid;
                if (id === result[r].id) {
                    result[r].running = true;
                    result[r].clientId = client.id;
                    if (client.is_focused)
                        result[r].active = true;
                    break;
                }
            }
        }

        return result;
    }

    readonly property int dockWidth: Math.max(iconSize + 24,
        entries.length * (iconSize + gap) + gap + 16)

    function launch(entry) {
        if (entry.clientId >= 0) {
            Mango.focusClient(entry.clientId);
            return;
        }
        if (entry.entry) {
            entry.entry.execute();
        } else {
            Quickshell.execDetached([entry.id]);
        }
    }

    function bottomMargin() {
        return (Settings.data.barPosition === "bottom"
            ? Theme.barHeight + 14 : 10);
    }

    Timer {
        id: hideTimer
        interval: 450
        onTriggered: {
            if (!dockRoot.hovered)
                dockRoot.revealed = false;
        }
    }

    // Invisible hover strip that reveals the dock when it is hidden.
    PanelWindow {
        id: triggerWindow
        screen: dockRoot.modelData
        visible: Settings.data.dockEnabled && dockRoot.autoHide && !dockRoot.revealed
        color: "transparent"
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        implicitWidth: Math.min(320, dockRoot.dockWidth + 80)
        implicitHeight: 6

        anchors {
            bottom: true
            left: true
        }

        margins {
            bottom: 0
            left: Math.max(0, ((screen ? screen.width : 1920) - implicitWidth) / 2)
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: dockRoot.revealed = true
        }
    }

    PanelWindow {
        id: dockWindow
        screen: dockRoot.modelData
        visible: dockRoot.shown
        color: "transparent"
        focusable: false
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        implicitWidth: dockRoot.dockWidth
        implicitHeight: dockRoot.iconSize + 20

        anchors {
            bottom: true
            left: true
        }

        margins {
            bottom: dockRoot.bottomMargin()
            left: Math.max(8, ((screen ? screen.width : 1920) - implicitWidth) / 2)
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.dockColor
            border.width: 1
            border.color: Utils.alpha(Theme.text, 0.08)

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onContainsMouseChanged: {
                    dockRoot.hovered = containsMouse;
                    if (containsMouse) {
                        dockRoot.revealed = true;
                        hideTimer.stop();
                    } else if (dockRoot.autoHide) {
                        hideTimer.restart();
                    }
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: dockRoot.gap

                Repeater {
                    model: dockRoot.entries

                    Item {
                        id: appItem
                        required property var modelData

                        width: dockRoot.iconSize
                        height: dockRoot.iconSize

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - 4
                            height: parent.height - 4
                            radius: Theme.radiusSmall
                            color: appMouse.containsMouse ? Theme.hover : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationFast }
                            }
                        }

                        AppIcon {
                            anchors.fill: parent
                            anchors.margins: 7
                            iconName: appItem.modelData.icon
                            size: dockRoot.iconSize
                            useFallbackColor: true
                        }

                        scale: appMouse.containsMouse ? 1.12 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.durationFast
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            visible: appItem.modelData.running
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -5
                            width: appItem.modelData.active ? 14 : 5
                            height: 3
                            radius: 2
                            color: appItem.modelData.active ? Theme.accent : Theme.subtext
                            opacity: appItem.modelData.active ? 1 : 0.6

                            Behavior on width {
                                NumberAnimation { duration: Theme.durationFast }
                            }
                        }

                        MouseArea {
                            id: appMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dockRoot.launch(appItem.modelData);
                                if (dockRoot.autoHide)
                                    dockRoot.revealed = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
