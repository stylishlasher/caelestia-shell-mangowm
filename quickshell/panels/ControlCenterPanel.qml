import QtQuick
import Quickshell
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "control"
    preferredWidth: 520
    preferredHeight: 680

    property int tab: 0
    readonly property var tabs: [
        { id: "quick", label: "Быстро" },
        { id: "audio", label: "Аудио" },
        { id: "network", label: "Сеть" },
        { id: "night", label: "Ночь" }
    ]

    Column {
        anchors.fill: parent
        spacing: 12

        Row {
            width: parent.width
            spacing: 8
            Text { text: "Центр управления"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontLarge; font.weight: Font.DemiBold }
            Item { width: 1; height: 1 }
            IconButton { glyph: "\uf013"; iconSize: 13; onClicked: Ui.open("settings", root.screen ? root.screen.name : "") }
            IconButton { glyph: "\uf00d"; iconSize: 12; tint: Theme.subtext; onClicked: Ui.close() }
        }

        Row {
            width: parent.width
            spacing: 8
            Repeater {
                model: root.tabs
                delegate: Chip {
                    required property var modelData
                    required property int index
                    label: modelData.label
                    active: root.tab === index
                    onClicked: root.tab = index
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        Flickable {
            width: parent.width
            height: parent.height - y
            clip: true
            contentHeight: contentCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentCol
                width: parent.width
                spacing: 10

                // Quick tab
                Column {
                    visible: root.tab === 0
                    width: parent.width
                    spacing: 10

                    SectionHeader { label: "Переключатели" }
                    Flow {
                        width: parent.width; spacing: 8
                        Chip { label: Audio.muted ? "Звук выкл" : "Звук"; glyph: Audio.muted ? "\uf026" : "\uf028"; active: !Audio.muted; onClicked: Audio.toggleMute() }
                        Chip { label: Audio.sourceMuted ? "Микрофон выкл" : "Микрофон"; glyph: "\uf130"; active: !Audio.sourceMuted; onClicked: Audio.toggleSourceMute() }
                        Chip { label: NightLight.enabled ? "Ночной свет" : "Ночной свет выкл"; glyph: "\uf186"; active: NightLight.enabled; onClicked: NightLight.setEnabled(!NightLight.enabled) }
                        Chip { label: Notifications.dnd ? "DND" : "Уведомления"; glyph: "\uf0f3"; active: !Notifications.dnd; onClicked: Notifications.toggleDnd() }
                    }

                    SectionHeader { label: "Громкость" }
                    StyledSlider { width: parent.width; from: 0; to: 1.5; value: Audio.volume; onMoved: v => Audio.setVolume(v) }
                    SectionHeader { label: "Яркость" }
                    StyledSlider { width: parent.width; from: 0; to: 100; value: Brightness.value || 0; onMoved: v => Brightness.setValue(Math.round(v)) }

                    SectionHeader { label: "Действия" }
                    Flow {
                        width: parent.width; spacing: 8
                        Chip { label: "Скриншот"; glyph: "\uf030"; onClicked: { Ui.close(); Utils.run("~/.config/mango/scripts/screenshot.sh region"); } }
                        Chip { label: "Обои"; glyph: "\uf03e"; onClicked: Ui.open("wallpaper", root.screen ? root.screen.name : "") }
                        Chip { label: "Буфер"; glyph: "\uf0ea"; onClicked: Ui.open("clipboard", root.screen ? root.screen.name : "") }
                        Chip { label: "Лаунчер"; glyph: "\uf002"; onClicked: Ui.open("launcher", root.screen ? root.screen.name : "") }
                    }
                }

                // Audio tab
                Column {
                    visible: root.tab === 1
                    width: parent.width
                    spacing: 8
                    SectionHeader { label: "Вывод" }
                    Repeater {
                        model: Audio.sinks
                        delegate: Rectangle {
                            required property var modelData
                            width: contentCol.width; height: 40; radius: 8
                            color: Audio.sink === modelData ? Utils.alpha(Theme.accent, 0.18) : Theme.hover
                            Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: Audio.nodeName(modelData); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; width: parent.width - 20; elide: Text.ElideRight }
                            MouseArea { anchors.fill: parent; onClicked: Audio.setDefaultSink(modelData) }
                        }
                    }
                    SectionHeader { label: "Потоки" }
                    Repeater {
                        model: Audio.streams
                        delegate: Column {
                            required property var modelData
                            width: contentCol.width
                            spacing: 2
                            Text { text: Audio.appName(modelData); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; elide: Text.ElideRight; width: parent.width }
                            StyledSlider { width: parent.width; from: 0; to: 1.5; value: modelData.audio ? modelData.audio.volume : 0; onMoved: v => Audio.setStreamVolume(modelData, v) }
                        }
                    }
                }

                // Network tab
                Column {
                    visible: root.tab === 2
                    width: parent.width
                    spacing: 8
                    SectionHeader { label: "Сеть" }
                    Text { text: "Откройте панель сети для полного управления."; color: Theme.subtext; font.family: Theme.font; font.pixelSize: Theme.fontSmall; wrapMode: Text.WordWrap; width: parent.width }
                    Chip { label: "Открыть сеть"; glyph: "\uf1eb"; onClicked: Ui.open("network", root.screen ? root.screen.name : "") }
                }

                // Night tab
                Column {
                    visible: root.tab === 3
                    width: parent.width
                    spacing: 10
                    SectionHeader { label: "Ночной свет" }
                    ToggleSwitch { checked: NightLight.enabled; onToggled: v => NightLight.setEnabled(v) }
                    Text { text: "Температура: " + NightLight.temperature + "K"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall }
                    StyledSlider { width: parent.width; from: 2500; to: 6500; value: NightLight.temperature; onMoved: v => NightLight.setTemperature(v) }
                }
            }
        }
    }
}
