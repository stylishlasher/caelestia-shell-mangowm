pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.services

Item {
    id: root
    property real value: 0
    property color fgColour: Colours.palette.m3primary
    property color bgColour: Colours.palette.m3secondaryContainer
    property bool wavy: false
    property real radius: height / 2
    property bool indeterminate: false
    implicitHeight: 8
    implicitWidth: 100

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.bgColour
    }
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: Math.max(0, Math.min(1, root.value)) * parent.width
        radius: root.radius
        color: root.fgColour
        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }
}
