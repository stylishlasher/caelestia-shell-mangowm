pragma ComponentBehavior: Bound
import QtQuick
import qs.components
import qs.services
Item {
    id: root
    required property var dialog
    StyledText { anchors.centerIn: parent; text: "File dialog unavailable in MangoWM port"; color: Colours.palette.m3onSurfaceVariant }
}
