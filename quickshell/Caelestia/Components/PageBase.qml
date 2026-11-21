import QtQuick
Item {
    id: root
    property string title: ""
    property string description: ""
    property var actions: []
    default property alias content: contentCol.data
    Column { id: contentCol; anchors.fill: parent }
}
