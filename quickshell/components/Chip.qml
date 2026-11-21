import QtQuick
import "../singletons"

Item {
    id: root

    property string label: ""
    property string glyph: ""
    property bool active: false
    property bool available: true

    signal clicked()

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 28
    opacity: available ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.active ? Utils.alpha(Theme.accent, 0.22)
             : (mouse.containsMouse ? Theme.hover : Utils.alpha(Theme.text, 0.05))
        border.width: root.active ? 1 : 0
        border.color: Utils.alpha(Theme.accent, 0.4)

        Behavior on color {
            ColorAnimation { duration: Theme.durationFast }
        }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.glyph.length > 0
            glyph: root.glyph
            size: 12
            color: root.active ? Theme.accent : Theme.subtext
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.active ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            font.weight: root.active ? Font.DemiBold : Font.Normal
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.available
        onClicked: root.clicked()
    }
}
