import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"
import "../components"

PanelWindow {
    id: root

    property var modelData: null
    screen: modelData

    readonly property string monitorName: modelData ? String(modelData.name) : ""
    readonly property bool activeScreen: {
        if (!Mango.ready || Mango.focusedName.length === 0)
            return Quickshell.screens.length > 0 && Quickshell.screens[0].name === root.monitorName;
        return Mango.focusedName === root.monitorName;
    }
    readonly property bool showing: Ui.osd.length > 0 && Settings.data.osdEnabled && root.activeScreen

    readonly property string glyph: {
        if (Ui.osd === "brightness")
            return "\uf0599";
        if (Ui.osd === "mic")
            return Ui.osdMuted ? "\uf0581" : "\uf0580";
        if (Ui.osdMuted || Ui.osdPercent <= 0)
            return "\uf0582";
        if (Ui.osdPercent < 33)
            return "\uf0580";
        if (Ui.osdPercent < 66)
            return "\uf057f";
        return "\uf057e";
    }

    readonly property string label: {
        if (Ui.osd === "brightness")
            return "Яркость";
        if (Ui.osd === "mic")
            return Ui.osdMuted ? "Микрофон выключен" : "Микрофон";
        return Ui.osdMuted ? "Звук выключен" : "Громкость";
    }

    readonly property color accentColor: Ui.osd === "brightness" ? Theme.yellow
        : (Ui.osdMuted ? Theme.red : Theme.accent)

    visible: surface.opacity > 0.01
    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    implicitWidth: 286
    implicitHeight: 74

    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: (Settings.data.barPosition === "bottom" ? Theme.barHeight : 0)
            + (Settings.data.dockEnabled ? Theme.dockHeight : 0) + 26
        left: Math.max(12, ((screen ? screen.width : 1920) - implicitWidth) / 2)
    }

    Item {
        id: surface
        anchors.fill: parent
        opacity: root.showing ? 1 : 0
        scale: root.showing ? 1 : 0.94
        transformOrigin: Item.Bottom

        Behavior on opacity {
            NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.panelColor
            border.width: 1
            border.color: Theme.outline

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: "transparent"
                border.width: 1
                border.color: Utils.alpha(Theme.text, 0.04)
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 38
                    height: 38
                    radius: 19
                    color: Utils.alpha(root.accentColor, 0.18)

                    Icon {
                        anchors.centerIn: parent
                        glyph: root.glyph
                        size: 18
                        color: root.accentColor
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 50
                    spacing: 5

                    Row {
                        width: parent.width

                        Text {
                            text: root.label
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                            font.weight: Font.Medium
                        }

                        Item { width: 1; height: 1 }

                        Text {
                            text: Ui.osdPercent + "%"
                            color: Theme.subtext
                            font.family: Theme.mono
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Utils.alpha(Theme.text, 0.12)

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, Ui.osdPercent / 100))
                            height: parent.height
                            radius: parent.radius
                            color: root.accentColor

                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.durationFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
