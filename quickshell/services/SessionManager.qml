pragma Singleton
import QtQuick
import Quickshell
Singleton {
    signal resumed()
    function lock() {}
    function unlock() {}
}
