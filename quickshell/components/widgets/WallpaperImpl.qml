import QtQuick
import Caelestia
import Caelestia.Config
import Caelestia.Multimedia
import Caelestia.State
import qs.services

Item {
    id: root
    property string source: Wallpapers.current
    property bool animate: true

    Image {
        id: a
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        source: root.source
        opacity: 1
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }
}
