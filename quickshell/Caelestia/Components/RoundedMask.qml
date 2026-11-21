import QtQuick

Item {
    id: root
    property var source: null
    property real radius: 0
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomRightRadius: radius
    property real bottomLeftRadius: radius
    property color color: "transparent"
    property bool smooth: true

    Rectangle {
        anchors.fill: parent
        color: root.color.a > 0 ? root.color : "transparent"
        radius: Math.max(root.topLeftRadius, root.topRightRadius, root.bottomRightRadius, root.bottomLeftRadius, root.radius)
        visible: color.a > 0
    }
}
