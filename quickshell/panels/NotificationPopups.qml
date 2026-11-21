import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../singletons"
import "../components"

Scope {
    id: root

    property var modelData: null

    readonly property string monitorName: modelData ? String(modelData.name) : ""
    readonly property bool onTop: Settings.data.barPosition === "top"
    readonly property bool activeScreen: {
        if (!Mango.ready || Mango.focusedName.length === 0)
            return Quickshell.screens.length > 0 && Quickshell.screens[0].name === root.monitorName;
        return Mango.focusedName === root.monitorName;
    }
    readonly property bool shown: Notifications.popups.length > 0
        && root.activeScreen && !Ui.locked

    PanelWindow {
        id: window
        screen: root.modelData
        visible: root.shown
        color: "transparent"
        focusable: false
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        implicitWidth: 368
        implicitHeight: Math.max(1, popupColumn.implicitHeight + 12)

        anchors {
            top: true
            right: true
        }

        margins {
            top: (root.onTop ? Theme.barHeight + 14 : 14)
            right: 14
        }

        Column {
            id: popupColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 6
            spacing: 8

            Repeater {
                model: Notifications.popups

                Rectangle {
                    id: popup
                    required property var modelData

                    readonly property var notification: popup.modelData.notification

                    width: popupColumn.width
                    height: Math.max(88, popupContent.implicitHeight + 20)
                    radius: Theme.radius
                    color: Theme.panelColor
                    border.width: 1
                    border.color: Theme.outline
                    opacity: 0
                    x: 20

                    Component.onCompleted: {
                        opacity = 1;
                        x = 0;
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.duration; easing.type: Easing.OutCubic }
                    }
                    Behavior on x {
                        NumberAnimation { duration: Theme.durationSlow; easing.type: Easing.OutCubic }
                    }
                    Behavior on height {
                        NumberAnimation { duration: Theme.durationFast }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: parent.radius - 1
                        color: "transparent"
                        border.width: 1
                        border.color: Utils.alpha(Theme.accent, 0.1)
                    }

                    Rectangle {
                        visible: popup.notification
                            && popup.notification.urgency === NotificationUrgency.Critical
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 8
                        width: 3
                        radius: 2
                        color: Theme.red
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: 30
                        anchors.bottomMargin: 2
                        onClicked: Notifications.dismiss(popup.notification)
                    }

                    AppIcon {
                        id: popupIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.top: parent.top
                        anchors.topMargin: 14
                        iconName: popup.notification
                            ? (popup.notification.appIcon || popup.notification.desktopEntry) : ""
                        size: 24
                    }

                    Column {
                        id: popupContent
                        anchors.left: popupIcon.right
                        anchors.leftMargin: 12
                        anchors.right: popupCloseButton.left
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Text {
                            width: parent.width
                            text: popup.notification
                                ? ((popup.notification.appName || "") + "  ·  "
                                    + (popup.notification.summary || "")) : ""
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            visible: popup.notification
                                && (popup.notification.body || "").length > 0
                            text: popup.notification ? popup.notification.body : ""
                            color: Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            lineHeight: 1.3
                        }

                        Row {
                            width: parent.width
                            spacing: 6
                            visible: popup.notification
                                && popup.notification.actions
                                && popup.notification.actions.length > 0

                            Repeater {
                                model: popup.notification && popup.notification.actions
                                    ? popup.notification.actions.slice(0, 2) : []

                                Chip {
                                    id: actionButton
                                    required property var modelData
                                    label: String(actionButton.modelData.text || "Действие")
                                    onClicked: {
                                        actionButton.modelData.invoke();
                                        Notifications.dismiss(popup.notification);
                                    }
                                }
                            }
                        }
                    }

                    IconButton {
                        id: popupCloseButton
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        glyph: "\uf00d"
                        iconSize: 10
                        padding: 5
                        tint: Theme.subtext
                        onClicked: Notifications.dismiss(popup.notification)
                    }
                }
            }
        }
    }
}
