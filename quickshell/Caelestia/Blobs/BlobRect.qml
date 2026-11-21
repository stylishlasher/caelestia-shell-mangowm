import QtQuick
import qs.services
import Caelestia.Config

Item {
    id: root
    property var group: null
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    property real radius: 0
    property real smoothing: 0
    property real borderLeft: 0
    property real borderRight: 0
    property real borderTop: 0
    property real borderBottom: 0
    property color color: Colours.tPalette.m3surface
    property real deformScale: 1
    property bool visibleWhenEmpty: true
    property var rawDeformMatrix: Qt.matrix4x4()
    property var deformMatrix: Qt.matrix4x4()

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.color
        visible: root.visibleWhenEmpty || parent.width > 0
    }
}
