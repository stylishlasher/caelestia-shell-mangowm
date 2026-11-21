import QtQuick
Item {
    id: root
    property var group: null
    property real radius: 0
    property real smoothing: 0
    property real borderLeft: 0
    property real borderRight: 0
    property real borderTop: 0
    property real borderBottom: 0
    property color color: "transparent"
    property real deformScale: 1
    property bool visibleWhenEmpty: true
}
