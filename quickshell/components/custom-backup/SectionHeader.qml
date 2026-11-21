import QtQuick
import "../singletons"

Text {
    id: root

    property string label: ""

    text: label.toUpperCase()
    color: Theme.subtext
    font.family: Theme.font
    font.pixelSize: Theme.fontTiny
    font.letterSpacing: 1.4
    font.weight: Font.DemiBold
    topPadding: 6
    bottomPadding: 2
}
