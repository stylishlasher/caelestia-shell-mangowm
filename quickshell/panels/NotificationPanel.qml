import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"
import "../components"

PanelWindow {
    id: root

    property var modelData: null
    screen: modelData

    readonly property bool opened: Ui.panel === "notifications"
        && (Ui.screenName === "" || Ui.screenName === (screen ? screen.name : ""))
    readonly property int panelW: Math.min(420, screen ? screen.width - 40 : 420)
    readonly property int panelH: (screen ? screen.height - Theme.barHeight - 30 : 700)

    visible: opened || bg.opacity > 0.01
    color: "transparent"
    focusable: opened
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    implicitWidth: panelW
    implicitHeight: panelH

    anchors { top: true; right: true; bottom: true }
    margins { top: Theme.barHeight + 10; right: 10; bottom: 10 }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.panelColor
        border.width: 1
        border.color: Utils.alpha(Theme.text, 0.08)
        opacity: root.opened ? 1 : 0
        x: root.opened ? 0 : 24
        Behavior on opacity { NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic } }
        Behavior on x { NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic } }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Row {
                width: parent.width
                spacing: 8
                Text { text: "Уведомления"; color: Theme.text; font.family: Theme.font; font.pixelSize: 18; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
                Item { width: 1; height: 1; Layout.fillWidth: true }
                Chip { label: Notifications.dnd ? "DND вкл" : "DND выкл"; active: Notifications.dnd; onClicked: Notifications.toggleDnd() }
                Chip { label: "Очистить"; onClicked: Notifications.dismissAll() }
                IconButton { glyph: "\uf00d"; iconSize: 12; tint: Theme.subtext; onClicked: Ui.close() }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            Flickable {
                width: parent.width
                height: parent.height - 60
                clip: true
                contentHeight: listCol.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: listCol
                    width: parent.width
                    spacing: 8

                    Text {
                        visible: (Notifications.tracked || []).length === 0
                        width: parent.width
                        text: "Нет уведомлений"
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        horizontalAlignment: Text.AlignHCenter
                        topPadding: 40
                    }

                    Repeater {
                        model: Notifications.tracked || []

                        Rectangle {
                            id: card
                            required property var modelData
                            width: listCol.width
                            implicitHeight: contentCol.implicitHeight + 20
                            radius: Theme.radiusSmall
                            color: Utils.alpha(Theme.surfaceHigh, 0.8)
                            border.width: 1
                            border.color: Theme.border

                            Column {
                                id: contentCol
                                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 4

                                Row {
                                    width: parent.width
                                    spacing: 8
                                    Text {
                                        text: card.modelData.appName || "Приложение"
                                        color: Theme.accent
                                        font.family: Theme.font; font.pixelSize: Theme.fontTiny; font.weight: Font.DemiBold
                                    }
                                    Item { width: 1; height: 1 }
                                    IconButton { glyph: "\uf00d"; iconSize: 10; tint: Theme.subtext; onClicked: Notifications.dismiss(card.modelData) }
                                }

                                Text {
                                    width: parent.width
                                    text: card.modelData.summary || ""
                                    color: Theme.text
                                    font.family: Theme.font; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
                                    wrapMode: Text.WordWrap
                                }
                                Text {
                                    width: parent.width
                                    visible: (card.modelData.body || "").length > 0
                                    text: card.modelData.body || ""
                                    color: Theme.subtext
                                    font.family: Theme.font; font.pixelSize: Theme.fontSmall
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 6
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
