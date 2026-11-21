import QtQuick
import Quickshell
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "power"
    preferredWidth: 520
    preferredHeight: 260

    readonly property var actions: [
        { name: "Блокировка", glyph: "\uf023", command: "exec \"$HOME/.config/mango/scripts/lock\" 2>/dev/null || loginctl lock-session", accent: Theme.accent },
        { name: "Выйти из сессии", glyph: "\uf08b", command: "mmsg dispatch quit 2>/dev/null || mmsg -d quit 2>/dev/null; sleep 1; pkill -TERM -x mango 2>/dev/null || true", accent: Theme.secondary },
        { name: "Сон", glyph: "\uf186", command: "systemctl suspend", accent: Theme.blue },
        { name: "Перезагрузка", glyph: "\uf021", command: "systemctl reboot", accent: Theme.yellow },
        { name: "Выключение", glyph: "\uf011", command: "systemctl poweroff", accent: Theme.red }
    ]

    Column {
        anchors.fill: parent
        spacing: 14

        Row {
            width: parent.width
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf011"
                size: 18
                color: Theme.accent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Питание"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }
        }

        Text {
            text: "Выберите действие"
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            Repeater {
                model: root.actions

                Rectangle {
                    id: card
                    required property var modelData
                    width: 86
                    height: 96
                    radius: Theme.radius
                    color: mouse.containsMouse ? Utils.alpha(modelData.accent, 0.18) : Theme.surfaceHigh
                    border.width: 1
                    border.color: mouse.containsMouse ? Utils.alpha(modelData.accent, 0.45) : Theme.border

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            glyph: card.modelData.glyph
                            size: 22
                            color: mouse.containsMouse ? card.modelData.accent : Theme.text
                        }

                        Text {
                            width: card.width - 12
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: card.modelData.name
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                            font.weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Ui.close();
                            const cmd = card.modelData.command;
                            if (cmd.indexOf("loginctl lock-session") !== -1 || cmd.indexOf("mango/scripts/lock") !== -1) {
                                Ui.lock();
                            }
                            Utils.run(cmd);
                        }
                    }
                }
            }
        }

        Chip {
            anchors.horizontalCenter: parent.horizontalCenter
            label: "Открыть mango-settings"
            glyph: "\uf013"
            onClicked: Utils.run("exec \"$HOME/.config/mango/scripts/launch\" settings")
        }
    }
}
