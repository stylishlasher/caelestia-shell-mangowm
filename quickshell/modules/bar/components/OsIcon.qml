import QtQuick
import Caelestia.Config
import Caelestia.State
import qs.components
import qs.services

Item {
    id: root
    implicitWidth: 28
    implicitHeight: 28

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const ss = ShellState.forActive();
            if (ss) ss.launcher = !ss.launcher;
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: "terminal"
        color: Colours.palette.m3tertiary
        font: Qt.font({ family: "Material Symbols Rounded", pointSize: 18 })
    }
}
