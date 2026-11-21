pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services
import Caelestia.State

Variants {
    model: Screens.screens

    Scope {
        id: scope

        required property var modelData

        Exclusions {
            screen: scope.modelData
            bar: content.bar
        }

        ContentWindow {
            id: content

            screen: scope.modelData
        }
    }
}
