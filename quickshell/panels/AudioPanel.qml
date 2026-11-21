import QtQuick
import Quickshell
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "audio"
    preferredWidth: 520
    preferredHeight: 560

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width
            spacing: 8
            Icon { glyph: "\uf028"; size: 18; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "Аудио"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontLarge; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
            Item { width: 1; height: 1 }
            IconButton { glyph: "\uf00d"; iconSize: 12; tint: Theme.subtext; onClicked: Ui.close() }
        }

        SectionHeader { label: "Вывод" }
        Repeater {
            model: Audio.sinks
            delegate: Rectangle {
                required property var modelData
                width: parent ? parent.width : 0
                height: 44
                radius: 10
                color: Audio.sink === modelData ? Utils.alpha(Theme.accent, 0.18) : Theme.hover
                border.width: 1
                border.color: Audio.sink === modelData ? Theme.accent : Theme.border
                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: Audio.nodeName(modelData); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; elide: Text.ElideRight }
                MouseArea { anchors.fill: parent; onClicked: Audio.setDefaultSink(modelData) }
            }
        }

        SectionHeader { label: "Ввод" }
        Repeater {
            model: Audio.sources
            delegate: Rectangle {
                required property var modelData
                width: parent ? parent.width : 0
                height: 40
                radius: 10
                color: Audio.source === modelData ? Utils.alpha(Theme.accent, 0.18) : Theme.hover
                border.width: 1
                border.color: Audio.source === modelData ? Theme.accent : Theme.border
                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: Audio.nodeName(modelData); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; elide: Text.ElideRight }
                MouseArea { anchors.fill: parent; onClicked: Audio.setDefaultSource(modelData) }
            }
        }

        SectionHeader { label: "Приложения" }
        Flickable {
            width: parent.width
            height: Math.max(120, parent.height - y - 10)
            clip: true
            contentHeight: streamsCol.implicitHeight
            Column {
                id: streamsCol
                width: parent.width
                spacing: 8
                Repeater {
                    model: Audio.streams
                    delegate: Rectangle {
                        required property var modelData
                        width: streamsCol.width
                        height: 56
                        radius: 10
                        color: Theme.hover
                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4
                            Row {
                                width: parent.width
                                Text { text: Audio.appName(modelData); color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontSmall; elide: Text.ElideRight; width: parent.width - 34 }
                                IconButton { glyph: modelData.audio && modelData.audio.muted ? "\uf026" : "\uf028"; iconSize: 12; onClicked: Audio.toggleStreamMute(modelData) }
                            }
                            StyledSlider {
                                width: parent.width
                                from: 0; to: 1.5
                                value: modelData.audio ? modelData.audio.volume : 0
                                onMoved: v => Audio.setStreamVolume(modelData, v)
                            }
                        }
                    }
                }
                Text {
                    visible: Audio.streams.length === 0
                    text: "Нет активных аудиопотоков"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }
            }
        }
    }
}
