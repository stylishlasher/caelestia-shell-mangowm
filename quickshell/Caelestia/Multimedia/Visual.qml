import QtQuick

Image {
    id: root
    asynchronous: true
    fillMode: Image.PreserveAspectCrop
    cache: true
    smooth: true
    property bool ready: status === Image.Ready
    property bool playing: true
    property bool animate: true
}
