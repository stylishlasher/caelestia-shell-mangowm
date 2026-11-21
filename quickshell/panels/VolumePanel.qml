import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "volume"
    preferredWidth: 450
    preferredHeight: 500

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var streams: {
        const nodes = Pipewire.nodes.values || [];
        const result = [];
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i];
            if (node && node.isStream && node.audio)
                result.push(node);
        }
        return result;
    }

    function nodeLabel(node) {
        if (!node)
            return "";
        const props = node.properties || {};
        return props["application.name"] || node.description || node.nickname || node.name || "Приложение";
    }

    function percent(value) {
        return Math.round(Math.max(0, Math.min(1, Number(value) || 0)) * 100) + "%";
    }

    function volumeIcon(muted, volume) {
        if (muted || volume <= 0.001)
            return "\uf026";
        if (volume < 0.33)
            return "\uf027";
        if (volume < 0.66)
            return "\uf028";
        return "\uf028";
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

            Row {
                width: parent.width
                spacing: 10
                bottomPadding: 10

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf028"
                    size: 17
                    color: Theme.accent
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Звук"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.fontLarge
                    font.weight: Font.DemiBold
                }
            }

            SectionHeader { label: "Вывод" }

            Row {
                width: parent.width
                spacing: 10
                topPadding: 4
                bottomPadding: 2

                IconButton {
                    glyph: root.volumeIcon(root.sink && root.sink.audio ? root.sink.audio.muted : false,
                                           root.sink && root.sink.audio ? root.sink.audio.volume : 0)
                    iconSize: 16
                    padding: 7
                    tint: root.sink && root.sink.audio && root.sink.audio.muted ? Theme.red : Theme.text
                    onClicked: {
                        if (root.sink && root.sink.audio)
                            root.sink.audio.muted = !root.sink.audio.muted;
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 130
                    spacing: 1

                    Text {
                        width: parent.width
                        text: root.sink
                            ? (root.sink.description || root.sink.nickname || root.sink.name || "Устройство вывода")
                            : "Нет устройства вывода"
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.sink && root.sink.audio
                            ? root.percent(root.sink.audio.volume) + (root.sink.audio.muted ? " · выключено" : "")
                            : "—"
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }

            StyledSlider {
                width: parent.width
                value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
                from: 0
                to: 1
                available: root.sink && root.sink.audio
                onMoved: value => {
                    if (root.sink && root.sink.audio) {
                        root.sink.audio.volume = value;
                        if (value > 0.001)
                            root.sink.audio.muted = false;
                    }
                }
            }

            Item { width: 1; height: 10 }

            SectionHeader { label: "Микрофон" }

            Row {
                width: parent.width
                spacing: 10
                topPadding: 4
                bottomPadding: 2

                IconButton {
                    glyph: root.source && root.source.audio && root.source.audio.muted
                        ? "\uf131" : "\uf027"
                    iconSize: 16
                    padding: 7
                    tint: root.source && root.source.audio && root.source.audio.muted
                        ? Theme.red : Theme.text
                    onClicked: {
                        if (root.source && root.source.audio)
                            root.source.audio.muted = !root.source.audio.muted;
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 130
                    spacing: 1

                    Text {
                        width: parent.width
                        text: root.source
                            ? (root.source.description || root.source.nickname || root.source.name || "Микрофон")
                            : "Нет устройства ввода"
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.source && root.source.audio
                            ? root.percent(root.source.audio.volume) + (root.source.audio.muted ? " · выключено" : "")
                            : "—"
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }

            StyledSlider {
                width: parent.width
                value: root.source && root.source.audio ? root.source.audio.volume : 0
                from: 0
                to: 1
                available: root.source && root.source.audio
                onMoved: value => {
                    if (root.source && root.source.audio) {
                        root.source.audio.volume = value;
                        if (value > 0.001)
                            root.source.audio.muted = false;
                    }
                }
            }

            Item { width: 1; height: 10 }

            SectionHeader { label: "Приложения" }

            Text {
                visible: root.streams.length === 0
                text: "Нет активных аудиопотоков"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                topPadding: 6
                bottomPadding: 6
            }

            Repeater {
                model: root.streams

                Column {
                    id: streamBlock
                    required property var modelData

                    width: body.width
                    spacing: 0
                    topPadding: 3
                    bottomPadding: 3

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 90
                            text: root.nodeLabel(streamBlock.modelData)
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                            elide: Text.ElideRight
                        }

                        IconButton {
                            anchors.verticalCenter: parent.verticalCenter
                            glyph: streamBlock.modelData.audio && streamBlock.modelData.audio.muted
                                ? "\uf131" : "\uf028"
                            iconSize: 11
                            padding: 5
                            tint: streamBlock.modelData.audio && streamBlock.modelData.audio.muted
                                ? Theme.red : Theme.subtext
                            onClicked: {
                                if (streamBlock.modelData.audio)
                                    streamBlock.modelData.audio.muted = !streamBlock.modelData.audio.muted;
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 40
                            horizontalAlignment: Text.AlignRight
                            text: streamBlock.modelData.audio
                                ? root.percent(streamBlock.modelData.audio.volume) : ""
                            color: Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                        }
                    }

                    StyledSlider {
                        width: parent.width
                        value: streamBlock.modelData.audio ? streamBlock.modelData.audio.volume : 0
                        from: 0
                        to: 1
                        onMoved: value => {
                            if (streamBlock.modelData.audio)
                                streamBlock.modelData.audio.volume = value;
                        }
                    }
                }
            }

            Item { width: 1; height: 12 }
        }
    }
}
