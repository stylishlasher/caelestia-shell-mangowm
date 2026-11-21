import QtQuick
QtObject {
    property var target: null
    property real progress: 0
    property real strokeWidth: 0
    property color color: "white"
    property color trackColor: "transparent"
    property real startAngle: 0
    property real sweepAngle: 360
    property int indeterminateAnimationType: 0
    property real startFraction: 0
    property real endFraction: 0.25
    property real rotation: 0
    property real completeEndProgress: 0
    property real duration: 1000
    property real completeEndDuration: 400
}
