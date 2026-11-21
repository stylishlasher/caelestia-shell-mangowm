pragma Singleton

import QtQuick
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.services
import qs.modules.nexus

Singleton {
    id: root

    function create(parent, props) {
        nexusComp.createObject(parent ?? dummy, props || {});
    }

    QtObject { id: dummy }

    Component {
        id: nexusComp

        FloatingWindow {
            id: win
            color: Colours.tPalette.m3surface
            onVisibleChanged: if (!visible) destroy()

            implicitWidth: nexus.implicitWidth
            implicitHeight: nexus.implicitHeight

            Nexus {
                id: nexus
                anchors.fill: parent
                nState.screen: win.screen
                nState.isWindow: true
                onClose: win.destroy()
            }
        }
    }
}
