import QtQuick
import Quickshell
import "../singletons"

Item {
    id: root

    property string iconName: ""
    property int size: 24
    property string fallbackGlyph: "\uf0c9"
    property bool useFallbackColor: false

    readonly property string resolved: {
        if (!iconName)
            return "";
        const value = String(iconName);
        if (value.startsWith("/"))
            return "file://" + value;
        return Quickshell.iconPath(value, true);
    }

    implicitWidth: size
    implicitHeight: size

    Image {
        id: image
        anchors.fill: parent
        anchors.margins: 2
        source: root.resolved
        sourceSize.width: Math.round(root.size * 2)
        sourceSize.height: Math.round(root.size * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: true
        visible: status === Image.Ready && root.resolved.length > 0
    }

    Icon {
        anchors.centerIn: parent
        visible: !image.visible
        glyph: root.fallbackGlyph
        size: Math.round(root.size * 0.72)
        color: root.useFallbackColor ? Theme.accent : Theme.text
    }
}
