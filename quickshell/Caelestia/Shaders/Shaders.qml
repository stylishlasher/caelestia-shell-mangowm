pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property var crossfade: ({ name: "crossfade", duration: 400, easing: Easing.InOutQuad, fragmentShader: "" })
    readonly property var fade: crossfade
    readonly property var slide: crossfade
    readonly property var wipe: crossfade
}
