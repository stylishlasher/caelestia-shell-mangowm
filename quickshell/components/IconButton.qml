import QtQuick
import "../singletons"

Item {
    id: root

    property string glyph: ""
    property int iconSize: 15
    property int padding: 7
    property bool active: false
    property bool available: true
    property bool bold: false
    property color tint: Theme.text
    property color activeTint: Theme.accent
    property color activeBackground: Utils.alpha(Theme.accent, 0.18)
    property string tooltip: ""

    signal clicked()
    signal rightClicked()

    implicitWidth: iconSize + padding * 2
    implicitHeight: iconSize + padding * 2
    opacity: available ? 1 : 0.38

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: root.active ? root.activeBackground
             : (mouse.containsMouse ? Theme.hover : "transparent")
        Behavior on color {
            ColorAnimation { duration: Theme.durationFast }
        }
    }

    Icon {
        anchors.centerIn: parent
        glyph: root.glyph
        size: root.iconSize
        bold: root.bold
        color: root.active ? root.activeTint : root.tint
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.available
        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }
    }
}
