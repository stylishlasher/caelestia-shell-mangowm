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

    visible: opened || panel.opacity > 0.01
    color: "transparent"
    focusable: opened
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    implicitWidth: Math.min(980, screen ? screen.width - 40 : 980)
    implicitHeight: Math.min(520, screen ? screen.height - 80 : 520)

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barHeight + 10; left: 20; right: 20 }

    HoverHandler { id: hover }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: if (!hover.hovered) Ui.close()
    }

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

        Row {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Left: quick info
            Column {
                width: parent.width * 0.34
                spacing: 12
                Text { text: Utils.clockText(new Date(), Settings.data.use24h, false); color: Theme.text; font.family: Theme.font; font.pixelSize: 42; font.weight: Font.Light }
                Text { text: Utils.dateText(new Date()); color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSize }
                Rectangle { width: parent.width; height: 1; color: Theme.border }
                Text { text: Weather.hasData ? (Weather.temperatureText(Weather.temperature) + " · " + Utils.weatherText(Weather.weatherCode)) : "Погода недоступна"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSize }
                Text { text: Weather.place || Settings.data.weatherCity; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                Rectangle { width: parent.width; height: 1; color: Theme.border }
                Text { text: Media.hasPlayer ? (Media.title + (Media.artist ? " — " + Media.artist : "")) : "Медиа не играет"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; wrapMode: Text.WordWrap; width: parent.width }
                Row { spacing: 8; IconButton { glyph: "\uf048"; iconSize: 14; onClicked: Media.previous() } IconButton { glyph: Media.playing ? "\uf04c" : "\uf04b"; iconSize: 14; onClicked: Media.toggle() } IconButton { glyph: "\uf051"; iconSize: 14; onClicked: Media.next() } }
            }

            Rectangle { width: 1; height: parent.height; color: Theme.border }

            // Center: shortcuts
            Column {
                width: parent.width * 0.30
                spacing: 10
                Text { text: "Быстрые действия"; color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                Flow {
                    width: parent.width; spacing: 8
                    Chip { label: "Лаунчер"; glyph: "\uf002"; onClicked: Ui.open("launcher", root.monitorName) }
                    Chip { label: "Обои"; glyph: "\uf03e"; onClicked: Ui.open("wallpaper", root.monitorName) }
                    Chip { label: "Буфер"; glyph: "\uf0ea"; onClicked: Ui.open("clipboard", root.monitorName) }
                    Chip { label: "Музыка"; glyph: "\uf001"; onClicked: Ui.open("music", root.monitorName) }
                    Chip { label: "Сеть"; glyph: "\uf1eb"; onClicked: Ui.open("network", root.monitorName) }
                    Chip { label: "Громкость"; glyph: "\uf028"; onClicked: Ui.open("volume", root.monitorName) }
                    Chip { label: "Настройки"; glyph: "\uf013"; onClicked: Ui.open("settings", root.monitorName) }
                    Chip { label: "Питание"; glyph: "\uf011"; onClicked: Ui.open("power", root.monitorName) }
                }
                Rectangle { width: parent.width; height: 1; color: Theme.border }
                Text { text: "Система"; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                Text { text: "Активное окно: " + (function(){ const c=Mango.clientsFor(root.monitorName); for(let i=0;i<c.length;i++) if(c[i].is_focused) return c[i].title||c[i].appid||""; return "—"; })(); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; width: parent.width; elide: Text.ElideRight }
                Text { text: "Layout: " + root.activeLayoutSafe(); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
            }

            Rectangle { width: 1; height: parent.height; color: Theme.border }

            // Right: notifications preview
            Column {
                width: parent.width - (parent.width * 0.64) - 32
                spacing: 10
                Row { width: parent.width; Text { text: "Уведомления"; color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold } Item { width: 1; height: 1 } Chip { label: "Все"; onClicked: Ui.open("notifications", root.monitorName) } }
                Flickable {
                    width: parent.width; height: parent.height - 34
                    clip: true; contentHeight: notifCol.implicitHeight; boundsBehavior: Flickable.StopAtBounds
                    Column {
                        id: notifCol; width: parent.width; spacing: 6
                        Text { visible: (Notifications.tracked||[]).length===0; text: "Пусто"; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                        Repeater {
                            model: (Notifications.tracked || []).slice(0, 6)
                            Rectangle {
                                required property var modelData
                                width: notifCol.width; implicitHeight: t.implicitHeight + 12; radius: 8; color: Utils.alpha(Theme.surfaceHigh, 0.7)
                                Text { id: t; anchors.margins: 6; anchors.fill: parent; text: (modelData.appName ? modelData.appName + ": " : "") + (modelData.summary || ""); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontTiny; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight }
                            }
                        }
                    }
                }
            }
        }
    }

    function activeLayoutSafe() {
        const m = Mango.monitorByName(root.monitorName);
        return m && m.layout_symbol ? m.layout_symbol : "T";
    }
}
