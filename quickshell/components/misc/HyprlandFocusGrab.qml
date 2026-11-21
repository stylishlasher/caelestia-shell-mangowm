import QtQuick

QtObject {
    id: root
    property bool active: false
    property var windows: []
    signal cleared()
    function clear() { cleared(); }
}
