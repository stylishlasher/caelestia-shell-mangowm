import QtQuick

ListView {
    id: root
    property bool incremental: true
    property var viewport: root
    property bool useCustomViewport: false
    property int readyDelay: 0
    property int cacheBuffer: 0
    property int removeDuration: 0
    property bool asynchronous: true
    property bool trackViewport: false
    clip: true
}
