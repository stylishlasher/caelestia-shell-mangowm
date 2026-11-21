import QtQuick

Item {
    id: root
    property int shape: 0
    property color color: "transparent"
    property real implicitSize: 24
    implicitWidth: implicitSize
    implicitHeight: implicitSize
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.color
        visible: root.color.a > 0
    }
}
