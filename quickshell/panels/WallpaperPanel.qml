import QtQuick
import Quickshell
import Quickshell.Io
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "wallpaper"
    preferredWidth: 760
    preferredHeight: 600

    property var wallpapers: []
    property bool scanning: false

    readonly property string directory: Utils.expand(Settings.data.wallpaperDir)
    readonly property string current: Settings.data.wallpaper

    function scan() {
        if (root.scanning)
            return;
        root.scanning = true;
        listProcess.running = false;
        listProcess.command = ["bash", "-c",
            "find \"$1\" -maxdepth 2 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' "
            + "-o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \\) "
            + "-printf '%p\\n' 2>/dev/null | sort",
            "_", root.directory];
        listProcess.running = true;
    }

    function apply(path) {
        Settings.data.wallpaper = path;
        Utils.run("stylish-set-wallpaper " + Utils.shq(path));
    }

    function fileName(path) {
        const parts = String(path).split("/");
        const name = parts.length > 0 ? parts[parts.length - 1] : path;
        return name.replace(/\.[^.]+$/, "");
    }

    onOpenedChanged: {
        if (opened)
            scan();
    }

    Process {
        id: listProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text || "").split("\n");
                const result = [];
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (line.length > 0)
                        result.push(line);
                }
                root.wallpapers = result;
                root.scanning = false;
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 12

        Row {
            width: parent.width
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf03e"
                size: 16
                color: Theme.accent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Обои"
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
                onClicked: root.scan()
            }

            Chip {
                anchors.verticalCenter: parent.verticalCenter
                label: "Случайные"
                glyph: "\uf074"
                onClicked: Utils.run("stylish-set-wallpaper --random")
            }

            Chip {
                anchors.verticalCenter: parent.verticalCenter
                label: "Папка"
                glyph: "\uf07b"
                onClicked: Utils.run("xdg-open " + Utils.shq(root.directory))
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf00d"
                iconSize: 13
                tint: Theme.subtext
                onClicked: Ui.close()
            }
        }

        Text {
            width: parent.width
            text: root.directory + " · " + root.wallpapers.length + " изображений"
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontTiny
            elide: Text.ElideMiddle
        }

        Item {
            width: parent.width
            height: parent.height - 40 - 24 - 12 * 2

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                cellWidth: Math.max(150, Math.floor(width / Math.max(2,
                    Math.min(4, Math.floor(width / 190)))))
                cellHeight: Math.round(cellWidth * 0.68) + 26
                model: root.wallpapers
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: wallpaperCell
                    required property var modelData

                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property bool selected: root.current === wallpaperCell.modelData

                    Rectangle {
                        id: thumb
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 5
                        height: parent.height - 31
                        radius: Theme.radiusSmall
                        color: Utils.alpha(Theme.text, 0.05)
                        clip: true
                        border.width: wallpaperCell.selected ? 2 : 1
                        border.color: wallpaperCell.selected
                            ? Theme.accent
                            : (thumbMouse.containsMouse ? Utils.alpha(Theme.text, 0.18) : "transparent")

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: "file://" + wallpaperCell.modelData
                            sourceSize.width: 380
                            sourceSize.height: 260
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }

                        Rectangle {
                            visible: wallpaperCell.selected
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 6
                            width: 20
                            height: 20
                            radius: 10
                            color: Theme.accent

                            Icon {
                                anchors.centerIn: parent
                                glyph: "\uf00c"
                                size: 11
                                color: Theme.onAccent
                            }
                        }

                        Rectangle {
                            visible: thumbMouse.containsMouse && !wallpaperCell.selected
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: 16
                            color: Utils.alpha(Theme.surface, 0.8)

                            Icon {
                                anchors.centerIn: parent
                                glyph: "\uf03e"
                                size: 14
                                color: Theme.text
                            }
                        }

                        MouseArea {
                            id: thumbMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.apply(wallpaperCell.modelData)
                        }

                        scale: thumbMouse.containsMouse ? 1.02 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.durationFast
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 7
                        anchors.rightMargin: 7
                        anchors.bottomMargin: 4
                        text: root.fileName(wallpaperCell.modelData)
                        color: wallpaperCell.selected ? Theme.accent : Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontTiny
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 40
                visible: root.wallpapers.length === 0 && !root.scanning
                text: "В папке нет изображений.\nДобавьте обои или запустите install.sh, чтобы установить сгенерированные."
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                lineHeight: 1.4
            }

            Text {
                anchors.centerIn: parent
                visible: root.scanning
                text: "Сканирование…"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }
        }
    }
}
