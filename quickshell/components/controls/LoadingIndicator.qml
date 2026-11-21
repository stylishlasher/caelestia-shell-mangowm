pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.services

Item {
    id: root
    property color color: Colours.palette.m3primary
    property real implicitSize: 38
    property bool containsIcon: false
    property bool animated: true
    implicitWidth: implicitSize
    implicitHeight: implicitSize

    Rectangle {
        anchors.centerIn: parent
        width: root.implicitSize * 0.6
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 3
        border.color: root.color
        opacity: 0.7
        RotationAnimator on rotation { from: 0; to: 360; duration: 900; loops: Animation.Infinite; running: root.animated }
    }
}
