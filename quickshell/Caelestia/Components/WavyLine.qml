import QtQuick

Item {
    id: root
    property real amplitude: 0
    property real amplitudeMultiplier: 0
    property real frequency: 0
    property real phase: 0
    property real waveProgress: 0
    property real value: 0
    property real startAngle: 0
    property real fullAngle: 360
    property real fullLength: 0
    property real startX: 0
    property real radius: 0
    property real lineWidth: 2
    property int pathType: 0
    property color color: "white"
    property real strokeWidth: 2
    implicitHeight: 20
    implicitWidth: 100
}
