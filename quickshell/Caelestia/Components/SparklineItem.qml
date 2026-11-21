import QtQuick
Item {
    id: root
    property var values: []
    property var line1: values
    property var values2: []
    property var line2: values2
    property color color: "white"
    property color color2: "white"
    property real strokeWidth: 2
    property int historyLength: 0
    property real maxValue: 1
    property real line2FillAlpha: 0
    property color line2Color: "white"
    property color lineColor: "white"
    property color line1Color: "white"
    property real fillAlpha: 0
    property real line1FillAlpha: 0
    implicitWidth: 100; implicitHeight: 40
}
