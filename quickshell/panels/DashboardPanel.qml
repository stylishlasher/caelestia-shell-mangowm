import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"
import "../components"

PanelWindow {
    id: root

    property var modelData: null
    screen: modelData

    readonly property bool opened: Ui.panel === "dashboard"
    readonly property string monitorName: screen ? screen.name : ""
    property int tab: 0
    readonly property var tabs: [
        { id: "overview", label: "Обзор", glyph: "\uf0e4" },
        { id: "media", label: "Медиа", glyph: "\uf001" },
        { id: "weather", label: "Погода", glyph: "\uf185" },
        { id: "notifications", label: "Уведомления", glyph: "\uf0f3" },
        { id: "system", label: "Система", glyph: "\uf085" }
    ]

    visible: opened || panel.opacity > 0.01
    color: "transparent"
    focusable: opened
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    implicitWidth: Math.min(980, screen ? screen.width - 40 : 980)
    implicitHeight: Math.min(560, screen ? screen.height - 80 : 560)

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barHeight + 10; left: 20; right: 20 }

    readonly property string activeWindowTitle: {
        const c = Mango.clientsFor(root.monitorName);
        for (let i = 0; i < c.length; i++) if (c[i].is_focused) return c[i].title || c[i].appid || "—";
        return "—";
    }
    readonly property string activeLayout: {
        const m = Mango.monitorByName(root.monitorName);
        return m && m.layout_symbol ? m.layout_symbol : "T";
    }

    HoverHandler { id: hover }
    Timer { id: closeTimer; interval: 250; onTriggered: if (!hover.hovered) Ui.close() }
    onOpenedChanged: if (!opened) closeTimer.stop()
    Connections { target: hover; function onHoveredChanged() { if (hover.hovered) closeTimer.stop(); else if (root.opened) closeTimer.restart(); } }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: Theme.radius + 4
        color: Theme.panelColor
        border.width: 1
        border.color: Utils.alpha(Theme.text, 0.08)
        opacity: root.opened ? 1 : 0
        y: root.opened ? 0 : -20
        Behavior on opacity { NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic } }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                width: parent.width
                spacing: 8
                Repeater {
                    model: root.tabs
                    delegate: Chip {
                        required property var modelData
                        required property int index
                        label: modelData.label
                        glyph: modelData.glyph
                        active: root.tab === index
                        onClicked: root.tab = index
                    }
                }
                Item { width: 1; height: 1 }
                IconButton { glyph: "\uf00d"; iconSize: 12; tint: Theme.subtext; onClicked: Ui.close() }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            Item {
                width: parent.width
                height: parent.height - 58

                // Overview
                Row {
                    anchors.fill: parent
                    spacing: 14
                    visible: root.tab === 0

                    Column {
                        width: parent.width * 0.34
                        spacing: 10
                        Text { text: Utils.clockText(new Date(), Settings.data.use24h, false); color: Theme.text; font.family: Theme.font; font.pixelSize: 44; font.weight: Font.Light }
                        Text { text: Utils.dateText(new Date()); color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSize }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Text { text: Weather.hasData ? (Weather.temperatureText(Weather.temperature) + " · " + Utils.weatherText(Weather.weatherCode)) : "Погода недоступна"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSize }
                        Text { text: Weather.place || Settings.data.weatherCity; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Text { text: "Активное окно"; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                        Text { text: root.activeWindowTitle; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; width: parent.width; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }
                    }

                    Rectangle { width: 1; height: parent.height; color: Theme.border }

                    Column {
                        width: parent.width * 0.30
                        spacing: 10
                        Text { text: "Быстрые действия"; color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Flow {
                            width: parent.width; spacing: 8
                            Chip { label: "Лаунчер"; glyph: "\uf002"; onClicked: Ui.open("launcher", root.monitorName) }
                            Chip { label: "Центр"; glyph: "\uf085"; onClicked: Ui.open("control", root.monitorName) }
                            Chip { label: "Обои"; glyph: "\uf03e"; onClicked: Ui.open("wallpaper", root.monitorName) }
                            Chip { label: "Буфер"; glyph: "\uf0ea"; onClicked: Ui.open("clipboard", root.monitorName) }
                            Chip { label: "Аудио"; glyph: "\uf028"; onClicked: Ui.open("audio", root.monitorName) }
                            Chip { label: "Сеть"; glyph: "\uf1eb"; onClicked: Ui.open("network", root.monitorName) }
                            Chip { label: "Настройки"; glyph: "\uf013"; onClicked: Ui.open("settings", root.monitorName) }
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Text { text: NightLight.enabled ? "Ночной свет: " + NightLight.temperature + "K" : "Ночной свет выключен"; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                        Chip { label: NightLight.enabled ? "Выключить ночь" : "Включить ночь"; glyph: "\uf186"; active: NightLight.enabled; onClicked: NightLight.setEnabled(!NightLight.enabled) }
                    }

                    Rectangle { width: 1; height: parent.height; color: Theme.border }

                    Column {
                        width: parent.width - (parent.width * 0.64) - 32
                        spacing: 8
                        Text { text: "Уведомления"; color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Flickable {
                            width: parent.width; height: parent.height - 30
                            clip: true; contentHeight: ncol.implicitHeight
                            Column {
                                id: ncol; width: parent.width; spacing: 6
                                Repeater {
                                    model: (Notifications.tracked || []).slice(0, 8)
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: ncol.width; implicitHeight: nt.implicitHeight + 12; radius: 8; color: Utils.alpha(Theme.surfaceHigh, 0.7)
                                        Text { id: nt; anchors.fill: parent; anchors.margins: 6; text: (modelData.appName ? modelData.appName + ": " : "") + (modelData.summary || ""); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontTiny; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }
                                    }
                                }
                                Text { visible: (Notifications.tracked||[]).length===0; text: "Нет уведомлений"; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                            }
                        }
                    }
                }

                // Media
                Column {
                    anchors.fill: parent; visible: root.tab === 1; spacing: 12
                    Text { text: Media.hasPlayer ? Media.title : "Ничего не играет"; color: Theme.text; font.family: Theme.font; font.pixelSize: 24; font.weight: Font.DemiBold; width: parent.width; elide: Text.ElideRight }
                    Text { text: Media.artist || Media.identity; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSize; width: parent.width; elide: Text.ElideRight }
                    Row { spacing: 10; IconButton { glyph: "\uf048"; iconSize: 18; onClicked: Media.previous() } IconButton { glyph: Media.playing ? "\uf04c" : "\uf04b"; iconSize: 18; onClicked: Media.toggle() } IconButton { glyph: "\uf051"; iconSize: 18; onClicked: Media.next() } }
                    StyledSlider { width: Math.min(500, parent.width); from: 0; to: 1; value: Media.position; onMoved: v => Media.seek(v) }
                }

                // Weather
                Column {
                    anchors.fill: parent; visible: root.tab === 2; spacing: 10
                    Text { text: Weather.place || Settings.data.weatherCity; color: Theme.text; font.family: Theme.font; font.pixelSize: 28; font.weight: Font.DemiBold }
                    Text { text: Weather.hasData ? (Weather.temperatureText(Weather.temperature) + " · " + Utils.weatherText(Weather.weatherCode)) : "Нет данных"; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSize }
                    Chip { label: "Обновить"; glyph: "\uf021"; onClicked: Weather.refresh() }
                }

                // Notifications
                Column {
                    anchors.fill: parent; visible: root.tab === 3; spacing: 8
                    Row { width: parent.width; Chip { label: Notifications.dnd ? "DND вкл" : "DND выкл"; active: Notifications.dnd; onClicked: Notifications.toggleDnd() } Item { width: 8; height: 1 } Chip { label: "Очистить"; onClicked: Notifications.dismissAll() } Item { width: 1; height: 1 } Chip { label: "Панель"; onClicked: Ui.open("notifications", root.monitorName) } }
                    Flickable {
                        width: parent.width; height: parent.height - 40; clip: true; contentHeight: dn.implicitHeight
                        Column {
                            id: dn; width: parent.width; spacing: 6
                            Repeater {
                                model: Notifications.tracked || []
                                delegate: Rectangle {
                                    required property var modelData
                                    width: dn.width; implicitHeight: dc.implicitHeight + 14; radius: 8; color: Utils.alpha(Theme.surfaceHigh, 0.7)
                                    Column { id: dc; anchors.fill: parent; anchors.margins: 8; spacing: 2; Text { text: modelData.appName || ""; color: Theme.accent; font.family: Theme.font; font.pixelSize: Theme.fontTiny } Text { text: modelData.summary || ""; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; wrapMode: Text.WordWrap; width: parent.width } Text { text: modelData.body || ""; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontTiny; wrapMode: Text.WordWrap; width: parent.width; maximumLineCount: 3; elide: Text.ElideRight } }
                                }
                            }
                        }
                    }
                }

                // System
                Column {
                    anchors.fill: parent; visible: root.tab === 4; spacing: 10
                    Text { text: "Система"; color: Theme.text; font.family: Theme.font; font.pixelSize: 22; font.weight: Font.DemiBold }
                    Text { text: "Монитор: " + root.monitorName; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                    Text { text: "Layout: " + root.activeLayout; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                    Flow { width: parent.width; spacing: 8; Chip { label: "Настройки"; glyph: "\uf013"; onClicked: Ui.open("settings", root.monitorName) } Chip { label: "Питание"; glyph: "\uf011"; onClicked: Ui.open("power", root.monitorName) } Chip { label: "Перезагрузить shell"; glyph: "\uf021"; onClicked: Utils.run("stylish-shell reload") } }
                }
            }
        }
    }
}
