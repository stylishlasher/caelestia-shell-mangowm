import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"

PanelWindow {
    id: root

    property var modelData: null
    screen: modelData

    property string panelName: ""
    property int preferredWidth: 440
    property int preferredHeight: 320

    default property alias content: host.data

    readonly property string monitorName: modelData ? String(modelData.name) : ""
    readonly property bool opened: Ui.panel === panelName
        && (Ui.screenName === "" || Ui.screenName === monitorName)

    readonly property int panelW: Math.min(preferredWidth, screen ? screen.width - 48 : preferredWidth)
    readonly property int panelH: Math.min(preferredHeight, screen ? screen.height - Theme.barHeight - 90 : preferredHeight)
    readonly property bool onTop: Settings.data.barPosition === "top"

    implicitWidth: panelW
    implicitHeight: panelH
    visible: opened || surface.opacity > 0.01
    color: "transparent"
    focusable: opened
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    anchors {
        top: onTop
        bottom: !onTop
        left: true
    }

    margins {
        top: onTop ? Theme.barHeight + 10 : 0
        bottom: !onTop ? Theme.barHeight + 10
            + (Settings.data.dockEnabled ? Theme.dockHeight + 10 : 0) : 0
        left: Math.max(12, ((screen ? screen.width : 1920) - panelW) / 2)
    }

    Item {
        id: surface
        anchors.fill: parent
        focus: root.opened
        opacity: root.opened ? 1 : 0
        scale: root.opened ? 1 : 0.97
        transformOrigin: root.onTop ? Item.Top : Item.Bottom

        Behavior on opacity {
            NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic }
        }

        Keys.onEscapePressed: Ui.close()

        Rectangle {
            id: background
            anchors.fill: parent
            radius: Theme.radius + 4
            color: Theme.panelColor
            border.width: 1
            border.color: Utils.alpha(Theme.text, 0.08)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: "transparent"
                border.width: 1
                border.color: Utils.alpha(Theme.text, 0.04)
            }
        }

        Item {
            id: host
            anchors.fill: parent
            anchors.margins: 18
        }
    }
}
