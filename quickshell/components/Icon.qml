import QtQuick
import "../singletons"

Text {
    id: root

    property string glyph: ""
    property int size: 16
    property bool bold: false

    text: glyph
    color: Theme.text
    font.family: Theme.iconFont
    font.pixelSize: size
    font.bold: bold
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
