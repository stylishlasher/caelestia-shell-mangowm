import QtQuick
import Quickshell
import Quickshell.Io
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "clipboard"
    preferredWidth: 480
    preferredHeight: 560

    property var items: []
    property string query: ""

    readonly property var filtered: {
        const text = root.query.trim().toLowerCase();
        if (text.length === 0)
            return root.items;
        const result = [];
        for (let i = 0; i < root.items.length; i++) {
            if (String(root.items[i].preview).toLowerCase().indexOf(text) !== -1)
                result.push(root.items[i]);
        }
        return result;
    }

    function parse(text) {
        const lines = String(text || "").split("\n");
        const list = [];
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line.length === 0)
                continue;
            const split = line.indexOf("\t");
            if (split === -1)
                continue;
            const id = parseInt(line.slice(0, split));
            if (isNaN(id))
                continue;
            const preview = line.slice(split + 1);
            list.push({
                id: id,
                preview: preview,
                image: preview.indexOf("binary data") !== -1
            });
        }
        root.items = list.slice(0, 300);
    }

    function refresh() {
        listProcess.running = false;
        listProcess.running = true;
    }

    function copy(id) {
        Utils.run("cliphist decode " + Number(id) + " | wl-copy");
        Ui.close();
    }

    function remove(id) {
        Utils.run("echo " + Number(id) + " | cliphist delete");
        refreshTimer.restart();
    }

    function wipe() {
        Utils.run("cliphist wipe");
        root.items = [];
    }

    onOpenedChanged: {
        if (opened)
            refresh();
    }

    Process {
        id: listProcess
        running: false
        command: ["cliphist", "list"]

        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Timer {
        id: refreshTimer
        interval: 300
        onTriggered: root.refresh()
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Row {
            width: parent.width
            spacing: 10
            height: 30

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf0ea"
                size: 17
                color: Theme.accent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Буфер обмена"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.weight: Font.DemiBold
            }

            Item { width: 1; height: 1 }

            Chip {
                anchors.verticalCenter: parent.verticalCenter
                label: "Обновить"
                glyph: "\uf021"
                onClicked: root.refresh()
            }

            Chip {
                anchors.verticalCenter: parent.verticalCenter
                label: "Очистить"
                glyph: "\uf074"
                onClicked: root.wipe()
            }
        }

        Row {
            width: parent.width
            spacing: 8

            Field {
                width: parent.width - 80
                placeholder: "Поиск по истории…"
                onTextChanged: root.query = text
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.filtered.length
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }
        }

        ListView {
            id: list
            width: parent.width
            height: Math.max(0, parent.height - 94)
            clip: true
            model: root.filtered
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: clipRow
                required property var modelData

                width: list.width
                height: 50

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: clipMouse.containsMouse ? Theme.hover : Utils.alpha(Theme.text, 0.03)
                }

                Icon {
                    id: clipIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: clipRow.modelData.image ? "\uf03e" : "\uf0ea"
                    size: 14
                    color: Theme.subtext
                }

                Text {
                    anchors.left: clipIcon.right
                    anchors.leftMargin: 10
                    anchors.right: deleteButton.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: clipRow.modelData.image
                        ? "Изображение"
                        : clipRow.modelData.preview.replace(/\s+/g, " ")
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.NoWrap
                }

                IconButton {
                    id: deleteButton
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf00d"
                    iconSize: 11
                    padding: 6
                    tint: Theme.subtext
                    onClicked: root.remove(clipRow.modelData.id)
                }

                MouseArea {
                    id: clipMouse
                    anchors.fill: parent
                    anchors.rightMargin: 34
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.copy(clipRow.modelData.id)
                }
            }
        }

        Text {
            width: parent.width
            visible: root.filtered.length === 0
            height: visible ? implicitHeight : 0
            text: "История пуста"
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
