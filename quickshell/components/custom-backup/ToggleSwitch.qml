import QtQuick
import "../singletons"

Item {
    id: root

    property bool checked: false
    property bool available: true

    signal toggled(bool value)

    implicitWidth: 42
    implicitHeight: 24
    opacity: available ? 1 : 0.4

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.accent : Utils.alpha(Theme.subtext, 0.28)
        border.width: 1
        border.color: root.checked ? "transparent" : Utils.alpha(Theme.subtext, 0.18)
        Behavior on color {
            ColorAnimation { duration: Theme.durationFast }
        }
    }

    Rectangle {
        id: knob
        width: 18
        height: 18
        radius: 9
        y: (parent.height - height) / 2
        x: root.checked ? parent.width - width - 3 : 3
        color: root.checked ? Theme.onAccent : Theme.text
        Behavior on x {
            NumberAnimation {
                duration: Theme.durationFast
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.available
        onClicked: root.toggled(!root.checked)
    }
}
