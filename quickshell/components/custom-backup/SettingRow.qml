import QtQuick
import "../singletons"

Item {
    id: root

    property string title: ""
    property string description: ""
    default property alias control: controls.data

    implicitHeight: description.length > 0 ? 54 : 40

    Column {
        anchors.left: parent.left
        anchors.right: controls.left
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            text: root.title
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: root.description.length > 0
            text: root.description
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            elide: Text.ElideRight
        }
    }

    Row {
        id: controls
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}
