import QtQuick
import "../singletons"

Rectangle {
    id: root

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder: ""
    property alias input: input
    signal accepted()

    implicitWidth: 200
    implicitHeight: 34
    radius: Theme.radiusSmall
    color: Utils.alpha(Theme.text, 0.05)
    border.width: input.activeFocus ? 1 : 0
    border.color: Utils.alpha(Theme.accent, 0.5)

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        selectByMouse: true
        selectionColor: Utils.alpha(Theme.accent, 0.4)
        selectedTextColor: Theme.text
        clip: true

        onAccepted: root.accepted()

        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        visible: input.text.length === 0 && !input.activeFocus
        text: root.placeholder
        color: Theme.subtext
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
    }
}
