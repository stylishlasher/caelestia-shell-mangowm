import QtQuick
import "../singletons"

Item {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1
    property bool available: true
    property color fillColor: Theme.accent
    property color trackColor: Utils.alpha(Theme.subtext, 0.22)
    property color knobColor: Theme.text

    signal moved(real value)

    implicitHeight: 24
    implicitWidth: 160
    opacity: available ? 1 : 0.4

    readonly property real ratio: {
        const span = root.to - root.from;
        if (span === 0)
            return 0;
        return Math.max(0, Math.min(1, (root.value - root.from) / span));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 5
        radius: height / 2
        color: root.trackColor
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, root.ratio * parent.width)
        height: 5
        radius: height / 2
        color: root.fillColor
        Behavior on width {
            NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        id: knob
        width: 15
        height: 15
        radius: 7.5
        y: (parent.height - height) / 2
        x: Math.max(0, Math.min(parent.width - width, root.ratio * parent.width - width / 2))
        color: root.knobColor
        border.width: 2
        border.color: Theme.surface
    }

    MouseArea {
        anchors.fill: parent
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.available

        function pick(x) {
            const r = Math.max(0, Math.min(1, x / Math.max(1, root.width)));
            root.moved(root.from + r * (root.to - root.from));
        }

        onPressed: mouse => pick(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                pick(mouse.x);
        }
        onWheel: wheel => {
            const step = (root.to - root.from) / 20;
            const next = Math.max(root.from, Math.min(root.to,
                root.value + (wheel.angleDelta.y > 0 ? step : -step)));
            root.moved(next);
        }
    }
}
