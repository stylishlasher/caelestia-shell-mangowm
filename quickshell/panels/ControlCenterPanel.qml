import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "control"
    preferredWidth: 540
    preferredHeight: 660

    property string pendingAction: ""

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool micMuted: source && source.audio ? source.audio.muted : false
    readonly property var adapter: Bluetooth.defaultAdapter

    readonly property var sinks: {
        const nodes = Pipewire.nodes.values || [];
        const result = [];
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i];
            if (!node || !node.audio || node.isStream)
                continue;
            const props = node.properties || {};
            const cls = String(props["media.class"] || "");
            if (cls.indexOf("Sink") === -1)
                continue;
            result.push(node);
        }
        return result;
    }

    function percent(value) {
        return Math.round(Math.max(0, Math.min(1, Number(value) || 0)) * 100) + "%";
    }

    function volumeIcon(muted, volume) {
        if (muted || volume <= 0.001)
            return "\uf0582";
        if (volume < 0.33)
            return "\uf0580";
        if (volume < 0.66)
            return "\uf057f";
        return "\uf057e";
    }

    function nodeLabel(node) {
        if (!node)
            return "";
        return node.description || node.nickname || node.name || "Устройство";
    }

    function setSink(node) {
        if (!node)
            return;
        Utils.run("wpctl set-default " + node.id);
    }

    function chooseAction(action) {
        if (root.pendingAction === action) {
            root.pendingAction = "";
            return;
        }
        root.pendingAction = action;
        confirmTimer.restart();
    }

    function performAction(action) {
        root.pendingAction = "";
        if (action === "lock") {
            Ui.close();
            Ui.lock();
        } else if (action === "logout") {
            Utils.run("mmsg dispatch quit");
        } else if (action === "reboot") {
            Utils.run("systemctl reboot");
        } else if (action === "poweroff") {
            Utils.run("systemctl poweroff");
        }
    }

    Timer {
        id: confirmTimer
        interval: 4000
        onTriggered: root.pendingAction = ""
    }

    Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: body.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: body
            width: parent.width - 6
            spacing: 2

            // Header ---------------------------------------------------------
            Row {
                width: parent.width
                spacing: 10
                bottomPadding: 10

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: Utils.clockText(new Date(), Settings.data.use24h, false)
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: Utils.dateText(new Date())
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                    }
                }

                Item { width: 1; height: 1 }

                Chip {
                    anchors.verticalCenter: parent.verticalCenter
                    label: Notifications.dnd ? "Не беспокоить" : "Уведомления"
                    glyph: Notifications.dnd ? "\uf009a" : "\uf009a"
                    active: Notifications.dnd
                    onClicked: Notifications.toggleDnd()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf0156"
                    iconSize: 13
                    tint: Theme.subtext
                    onClicked: Ui.close()
                }
            }

            // Quick tiles ----------------------------------------------------
            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: (parent.width - 24) / 4
                    height: 62
                    radius: Theme.radiusSmall
                    color: Networking.wifiEnabled
                        ? Utils.alpha(Theme.accent, 0.18) : Utils.alpha(Theme.text, 0.05)
                    border.width: 1
                    border.color: Networking.wifiEnabled
                        ? Utils.alpha(Theme.accent, 0.32) : "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            glyph: Networking.connectivity === NetworkConnectivity.None
                                ? "\uf05aa" : "\uf05a9"
                            size: 17
                            color: Networking.wifiEnabled ? Theme.accent : Theme.subtext
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Networking.wifiEnabled ? "Wi-Fi" : "Wi-Fi выкл"
                            color: Networking.wifiEnabled ? Theme.text : Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                    }
                }

                Rectangle {
                    width: (parent.width - 24) / 4
                    height: 62
                    radius: Theme.radiusSmall
                    color: root.adapter && root.adapter.enabled
                        ? Utils.alpha(Theme.accent, 0.18) : Utils.alpha(Theme.text, 0.05)
                    border.width: 1
                    border.color: root.adapter && root.adapter.enabled
                        ? Utils.alpha(Theme.accent, 0.32) : "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            glyph: "\uf00af"
                            size: 17
                            color: root.adapter && root.adapter.enabled ? Theme.accent : Theme.subtext
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.adapter ? (root.adapter.enabled ? "Bluetooth" : "BT выкл") : "Нет BT"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.adapter !== null
                        onClicked: {
                            if (root.adapter)
                                root.adapter.enabled = !root.adapter.enabled;
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 24) / 4
                    height: 62
                    radius: Theme.radiusSmall
                    color: Notifications.dnd
                        ? Utils.alpha(Theme.accent, 0.18) : Utils.alpha(Theme.text, 0.05)
                    border.width: 1
                    border.color: Notifications.dnd
                        ? Utils.alpha(Theme.accent, 0.32) : "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            glyph: "\uf009a"
                            size: 17
                            color: Notifications.dnd ? Theme.accent : Theme.subtext
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Notifications.dnd ? "Тишина" : "Звук"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.toggleDnd()
                    }
                }

                Rectangle {
                    width: (parent.width - 24) / 4
                    height: 62
                    radius: Theme.radiusSmall
                    color: root.micMuted
                        ? Utils.alpha(Theme.red, 0.16) : Utils.alpha(Theme.text, 0.05)
                    border.width: 1
                    border.color: root.micMuted ? Utils.alpha(Theme.red, 0.3) : "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            glyph: root.micMuted ? "\uf0581" : "\uf0580"
                            size: 17
                            color: root.micMuted ? Theme.red : Theme.subtext
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.micMuted ? "Микрофон выкл" : "Микрофон"
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.source && root.source.audio
                        onClicked: {
                            if (root.source && root.source.audio)
                                root.source.audio.muted = !root.source.audio.muted;
                        }
                    }
                }
            }

            // Sliders --------------------------------------------------------
            Item { width: 1; height: 12 }

            Row {
                width: parent.width
                spacing: 10

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: root.volumeIcon(root.sink && root.sink.audio ? root.sink.audio.muted : false,
                                           root.sink && root.sink.audio ? root.sink.audio.volume : 0)
                    iconSize: 15
                    tint: root.sink && root.sink.audio && root.sink.audio.muted
                        ? Theme.red : Theme.text
                    onClicked: {
                        if (root.sink && root.sink.audio)
                            root.sink.audio.muted = !root.sink.audio.muted;
                    }
                }

                StyledSlider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 100
                    value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
                    onMoved: value => {
                        if (root.sink && root.sink.audio) {
                            root.sink.audio.volume = value;
                            if (value > 0.001)
                                root.sink.audio.muted = false;
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    horizontalAlignment: Text.AlignRight
                    text: root.sink && root.sink.audio ? root.percent(root.sink.audio.volume) : "—"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }
            }

            Item { width: 1; height: 6 }

            Row {
                width: parent.width
                spacing: 10

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf0599"
                    iconSize: 15
                    tint: Theme.text
                    available: Brightness.available
                    onClicked: Brightness.toggle()
                }

                StyledSlider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 100
                    value: Brightness.level / 100
                    from: 0.01
                    to: 1
                    available: Brightness.available
                    fillColor: Theme.yellow
                    onMoved: value => Brightness.setLevel(value * 100)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    horizontalAlignment: Text.AlignRight
                    text: Brightness.available ? (Brightness.level + "%") : "—"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }
            }

            // Output devices -------------------------------------------------
            Text {
                visible: root.sinks.length > 1
                text: "ВЫВОД ЗВУКА"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
                font.letterSpacing: 1.4
                font.weight: Font.DemiBold
                topPadding: 12
                bottomPadding: 4
            }

            Flow {
                width: parent.width
                spacing: 6
                visible: root.sinks.length > 1

                Repeater {
                    model: root.sinks

                    Chip {
                        id: sinkChip
                        required property var modelData
                        label: root.nodeLabel(sinkChip.modelData)
                        glyph: "\uf057e"
                        active: root.sink && root.sink.id === sinkChip.modelData.id
                        onClicked: root.setSink(sinkChip.modelData)
                    }
                }
            }

            // Notifications --------------------------------------------------
            Row {
                width: parent.width
                topPadding: 14
                bottomPadding: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "УВЕДОМЛЕНИЯ"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontTiny
                    font.letterSpacing: 1.4
                    font.weight: Font.DemiBold
                }

                Item { width: 1; height: 1 }

                Chip {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Notifications.tracked.length > 0
                    label: "Очистить"
                    glyph: "\uf01b4"
                    onClicked: Notifications.dismissAll()
                }
            }

            Text {
                width: parent.width
                visible: Notifications.tracked.length === 0
                text: Notifications.dnd ? "Режим «не беспокоить» включён" : "Новых уведомлений нет"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                topPadding: 6
                bottomPadding: 6
            }

            Column {
                width: parent.width
                spacing: 4

                Repeater {
                    model: Notifications.tracked

                    Rectangle {
                        id: notifRow
                        required property var modelData

                        width: parent.width
                        height: Math.max(56, notifContent.implicitHeight + 20)
                        radius: Theme.radiusSmall
                        color: Utils.alpha(Theme.text, 0.04)

                        AppIcon {
                            id: notifIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            iconName: notifRow.modelData.appIcon || notifRow.modelData.desktopEntry
                            size: 22
                        }

                        Column {
                            id: notifContent
                            anchors.left: notifIcon.right
                            anchors.leftMargin: 10
                            anchors.right: notifClose.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: {
                                    const app = notifRow.modelData.appName || "";
                                    const summary = notifRow.modelData.summary || "";
                                    return app.length > 0 ? (app + " · " + summary) : summary;
                                }
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                visible: (notifRow.modelData.body || "").length > 0
                                text: notifRow.modelData.body || ""
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontTiny
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }

                        IconButton {
                            id: notifClose
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.top: parent.top
                            anchors.topMargin: 4
                            glyph: "\uf0156"
                            iconSize: 10
                            padding: 5
                            tint: Theme.subtext
                            onClicked: Notifications.dismiss(notifRow.modelData)
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.rightMargin: 32
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                const actions = notifRow.modelData.actions || [];
                                if (actions.length > 0)
                                    actions[0].invoke();
                            }
                        }
                    }
                }
            }

            // Session --------------------------------------------------------
            Text {
                text: "СЕССИЯ"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
                font.letterSpacing: 1.4
                font.weight: Font.DemiBold
                topPadding: 14
                bottomPadding: 6
            }

            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [
                        { id: "lock", label: "Блокировка", glyph: "\uf033e" },
                        { id: "logout", label: "Выйти", glyph: "\uf0343" },
                        { id: "reboot", label: "Перезагрузка", glyph: "\uf0709" },
                        { id: "poweroff", label: "Выключить", glyph: "\uf0425" }
                    ]

                    Rectangle {
                        id: sessionChip
                        required property var modelData
                        width: (body.width - 24) / 4
                        height: 40
                        radius: Theme.radiusSmall
                        color: root.pendingAction === sessionChip.modelData.id
                            ? Utils.alpha(Theme.red, 0.22)
                            : (sessionMouse.containsMouse ? Theme.hover : Utils.alpha(Theme.text, 0.05))
                        border.width: root.pendingAction === sessionChip.modelData.id ? 1 : 0
                        border.color: Utils.alpha(Theme.red, 0.4)

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                glyph: sessionChip.modelData.glyph
                                size: 12
                                color: root.pendingAction === sessionChip.modelData.id
                                    ? Theme.red : Theme.subtext
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.pendingAction === sessionChip.modelData.id
                                    ? "Точно?" : sessionChip.modelData.label
                                color: root.pendingAction === sessionChip.modelData.id
                                    ? Theme.red : Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontTiny
                                font.weight: Font.Medium
                            }
                        }

                        MouseArea {
                            id: sessionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (sessionChip.modelData.id === "lock") {
                                    root.performAction("lock");
                                } else if (root.pendingAction === sessionChip.modelData.id) {
                                    root.performAction(sessionChip.modelData.id);
                                } else {
                                    root.chooseAction(sessionChip.modelData.id);
                                }
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 14 }
        }
    }

    onOpenedChanged: {
        if (opened)
            Notifications.markRead();
    }
}
