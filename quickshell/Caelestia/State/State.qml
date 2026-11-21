pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property var notifs: ({ muted: false })
    property var settings: ({})
    property var launcher: ({})
    property var dashboard: ({})
}
