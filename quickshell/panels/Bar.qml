import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import "../singletons"
import "../components"

PanelWindow {
    id: root

    property var modelData: null
    screen: modelData

    readonly property string monitorName: screen ? screen.name : ""
    readonly property bool onTop: Settings.data.barPosition === "top"

    readonly property var tagList: {
        const live = Mango.tagsFor(root.monitorName);
        if (live.length > 0)
            return live;
        const placeholder = [];
        for (let i = 1; i <= Settings.data.tagCount; i++)
            placeholder.push({
                index: i,
                is_active: i === 1,
                is_urgent: false,
                client_count: 0,
                layout: "T"
            });
        return placeholder;
    }

    readonly property string activeLayout: {
        const monitor = Mango.monitorByName(root.monitorName);
        return monitor && monitor.layout_symbol ? monitor.layout_symbol : "T";
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real sinkVolume: sink && sink.audio ? sink.audio.volume : 0
    readonly property var battery: UPower.displayDevice
    readonly property var wifiDevice: {
        const devices = Networking.devices.values || [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i] && devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }
    readonly property bool btAvailable: Bluetooth.defaultAdapter !== null

    SystemClock {
        id: clock
        precision: Settings.data.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    implicitHeight: Theme.barHeight
    visible: Settings.data.barEnabled
    color: "transparent"
    focusable: false
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.barHeight + 8

    anchors {
        top: onTop
        bottom: !onTop
        left: true
        right: true
    }

    margins {
        top: onTop ? 6 : 0
        bottom: !onTop ? 6 : 0
        left: 8
        right: 8
    }

    function volumeGlyph() {
        if (root.muted || root.sinkVolume <= 0.001)
            return "\uf026";
        if (root.sinkVolume < 0.33)
            return "\uf027";
        if (root.sinkVolume < 0.66)
            return "\uf028";
        return "\uf028";
    }

    function networkGlyph() {
        if (Networking.connectivity === NetworkConnectivity.None)
            return "\uf071";
        if (root.wifiDevice && root.wifiDevice.connected)
            return "\uf1eb";
        return "\uf0ac";
    }

    function batteryGlyph() {
        if (!root.battery || !root.battery.isPresent)
            return "\uf240";
        if (root.battery.state === UPowerDeviceState.Charging
                || root.battery.state === UPowerDeviceState.FullyCharged)
            return "\uf1e6";
        return "\uf240";
    }

    function toggleVolumeMute() {
        if (root.sink && root.sink.audio)
            root.sink.audio.muted = !root.sink.audio.muted;
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.barColor
        border.width: 1
        border.color: Utils.alpha(Theme.text, 0.07)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => {
                const delta = wheel.angleDelta.y > 0 ? -1 : 1;
                const list = root.tagList;
                let index = 0;
                for (let i = 0; i < list.length; i++) {
                    if (list[i].is_active) {
                        index = i;
                        break;
                    }
                }
                const next = list[Math.max(0, Math.min(list.length - 1, index + delta))];
                if (next)
                    Mango.view(root.monitorName, next.index);
            }
        }

        // Left cluster ------------------------------------------------------
        Row {
            id: left
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            IconButton {
                glyph: "\uf0c9"
                iconSize: 15
                active: Ui.panel === "launcher"
                onClicked: Ui.toggle("launcher", root.monitorName)
            }

            Row {
                id: tags
                spacing: 3
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: Settings.data.showTags ? root.tagList : []

                    Item {
                        id: tagItem
                        required property var modelData

                        readonly property bool active: modelData.is_active === true
                        readonly property bool occupied: (modelData.client_count || 0) > 0
                        readonly property bool urgent: modelData.is_urgent === true

                        width: active ? 30 : 24
                        height: 24

                        Behavior on width {
                            NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: tagItem.active ? Theme.accent
                                 : (tagMouse.containsMouse ? Theme.hover
                                 : (tagItem.occupied ? Utils.alpha(Theme.text, 0.07) : "transparent"))
                            border.width: tagItem.occupied && !tagItem.active ? 1 : 0
                            border.color: Utils.alpha(Theme.text, 0.06)

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationFast }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: tagItem.modelData.index
                            color: tagItem.active ? Theme.onAccent
                                 : (tagItem.occupied ? Theme.text : Theme.subtext)
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                            font.weight: tagItem.active ? Font.Bold : Font.Medium
                        }

                        Rectangle {
                            visible: tagItem.urgent
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.rightMargin: 3
                            anchors.topMargin: 3
                            width: 5
                            height: 5
                            radius: 3
                            color: Theme.red
                        }

                        MouseArea {
                            id: tagMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton)
                                    Mango.tagWindow(root.monitorName, tagItem.modelData.index);
                                else
                                    Mango.view(root.monitorName, tagItem.modelData.index);
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: layoutLabel.implicitWidth + 14
                height: 22
                radius: 7
                anchors.verticalCenter: parent.verticalCenter
                color: layoutMouse.containsMouse ? Theme.hover : Utils.alpha(Theme.text, 0.05)

                Text {
                    id: layoutLabel
                    anchors.centerIn: parent
                    text: root.activeLayout
                    color: Theme.subtext
                    font.family: Theme.mono
                    font.pixelSize: Theme.fontTiny
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: layoutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Mango.nextLayout()
                }
            }
        }

        // Center cluster ----------------------------------------------------
        Row {
            id: center
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                visible: Settings.data.showMedia && Media.hasPlayer
                width: Math.min(230, mediaRow.implicitWidth + 20)
                height: 26
                radius: 8
                color: mediaMouse.containsMouse ? Theme.hover : "transparent"

                Row {
                    id: mediaRow
                    anchors.centerIn: parent
                    spacing: 7

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        glyph: "\uf001"
                        size: 13
                        color: Media.playing ? Theme.accent : Theme.subtext
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(185, implicitWidth)
                        text: Media.title.length > 0 ? Media.title : Media.identity
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: mediaMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Ui.toggle("music", root.monitorName)
                }
            }

            Item {
                width: clockRow.implicitWidth + 16
                height: 26

                Row {
                    id: clockRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Settings.data.showClock
                        text: Utils.clockText(clock.date, Settings.data.use24h, Settings.data.showSeconds)
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Weather.hasData && Settings.data.showClock
                        text: Utils.weatherIcon(Weather.weatherCode, Weather.isDay)
                        color: Theme.subtext
                        font.family: Theme.iconFont
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Ui.toggle("time", root.monitorName)
                }
            }

            Rectangle {
                visible: Settings.data.showLanguage
                width: languageText.implicitWidth + 14
                height: 22
                radius: 7
                color: Utils.alpha(Theme.text, 0.05)

                Text {
                    id: languageText
                    anchors.centerIn: parent
                    text: Utils.layoutLabel(Mango.layout)
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontTiny
                    font.weight: Font.DemiBold
                }
            }
        }

        // Right cluster -----------------------------------------------------
        Row {
            id: right
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Row {
                visible: Settings.data.showTray
                spacing: 1
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: Settings.data.showTray ? SystemTray.items.values : []

                    Item {
                        id: trayItem
                        required property var modelData
                        width: 22
                        height: 22

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: trayMouse.containsMouse ? Theme.hover : "transparent"
                        }

                        AppIcon {
                            anchors.fill: parent
                            anchors.margins: 4
                            iconName: trayItem.modelData.icon
                            size: 14
                            useFallbackColor: true
                        }

                        MouseArea {
                            id: trayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (trayItem.modelData.onlyMenu)
                                    trayItem.modelData.activate();
                                else
                                    trayItem.modelData.activate();
                            }
                        }
                    }
                }
            }

            IconButton {
                visible: Settings.data.showNetwork
                glyph: root.networkGlyph()
                iconSize: 14
                active: Ui.panel === "network"
                onClicked: Ui.toggle("network", root.monitorName)
            }

            IconButton {
                visible: Settings.data.showBluetooth && root.btAvailable
                glyph: "\uf294"
                iconSize: 14
                active: Ui.panel === "network"
                tint: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                    ? Theme.text : Theme.subtext
                onClicked: Ui.toggle("network", root.monitorName)
            }

            IconButton {
                visible: Settings.data.showVolume
                glyph: root.volumeGlyph()
                iconSize: 14
                active: Ui.panel === "volume"
                onClicked: Ui.toggle("volume", root.monitorName)
                onRightClicked: root.toggleVolumeMute()
            }

            Item {
                visible: Settings.data.showBattery && root.battery && root.battery.isPresent
                width: batteryRow.implicitWidth + 12
                height: 24

                Row {
                    id: batteryRow
                    anchors.centerIn: parent
                    spacing: 4

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        glyph: root.batteryGlyph()
                        size: 13
                        color: root.battery && root.battery.percentage <= 15
                            ? Theme.red : Theme.text
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.battery ? Math.round(root.battery.percentage) + "%" : ""
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }

            IconButton {
                visible: Settings.data.showNotifications
                glyph: "\uf0f3"
                iconSize: 14
                active: Ui.panel === "control"
                onClicked: {
                    Ui.toggle("control", root.monitorName);
                    Notifications.markRead();
                }

                Rectangle {
                    visible: Notifications.unread > 0
                    width: 6
                    height: 6
                    radius: 3
                    color: Theme.red
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                }
            }

            IconButton {
                glyph: "\uf013"
                iconSize: 14
                active: Ui.panel === "settings"
                onClicked: Ui.toggle("settings", root.monitorName)
            }

            IconButton {
                visible: Settings.data.showPower
                glyph: "\uf011"
                iconSize: 14
                active: Ui.panel === "power"
                onClicked: Ui.toggle("power", root.monitorName)
            }
        }
    }
}
