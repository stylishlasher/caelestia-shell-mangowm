pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.services

LazyListView {
    id: root

    required property Props props
    required property Flickable container
    required property ScreenState screenState

    anchors.left: parent?.left
    anchors.right: parent?.right
    implicitHeight: contentHeight

    spacing: Tokens.spacing.small
    readyDelay: 1
    cacheBuffer: 400
    asynchronous: true

    useCustomViewport: true
    viewport: Qt.rect(0, container.contentY, width, container.height)

    model: ScriptModel {
        values: {
            const map = new Map();
            for (const n of Notifs.notClosed)
                map.set(n.appName, null);
            for (const n of Notifs.list)
                map.set(n.appName, null);
            return [...map.keys()];
        }
    }

    delegate: Component {
        MouseArea {
            id: notif

            required property int index
            required property string modelData

            readonly property bool closed: notifInner.notifCount === 0
            property int startY

            function closeAll(): void {
                clearTimer.start();
            }

            property bool lazyTrackViewport; lazyTrackViewport: !notifInner.expanded && notifInner.nonAnimHeight < notifInner.implicitHeight
            property real lazyPreferredHeight; lazyPreferredHeight: closed ? 0 : notifInner.nonAnimHeight
            property real lazyVisibleHeight; lazyVisibleHeight: notifInner.implicitHeight
            implicitHeight: notifInner.implicitHeight

            opacity: false || closed || false ? 0 : 1
            scale: false || closed ? 0.6 : false ? 0 : 1

            hoverEnabled: true
            cursorShape: pressed ? Qt.ClosedHandCursor : undefined
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            preventStealing: true
            enabled: !closed

            drag.target: this
            drag.axis: Drag.XAxis

            onPressed: event => {
                startY = event.y;
                if (event.button === Qt.RightButton)
                    notifInner.toggleExpand(!notifInner.expanded);
                else if (event.button === Qt.MiddleButton)
                    closeAll();
            }
            onPositionChanged: event => {
                if (pressed) {
                    const diffY = event.y - startY;
                    if (Math.abs(diffY) > Config.notifs.expandThreshold)
                        notifInner.toggleExpand(diffY > 0);
                }
            }
            onReleased: event => {
                if (Math.abs(x) < width * Config.notifs.clearThreshold)
                    x = 0;
                else
                    closeAll();
            }

            Timer {
                id: clearTimer

                interval: 15
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    const notifs = Notifs.notClosed.filter(n => n.appName === notif.modelData);
                    if (notifs.length === 0) {
                        stop();
                        return;
                    }

                    for (const n of notifs.slice(0, 30))
                        n.close();
                }
            }

            NotifGroup {
                id: notifInner

                modelData: notif.modelData
                props: root.props
                container: root.container
                screenState: root.screenState
            }

            Behavior on y {
                enabled: notif.LazyListView.ready

                Anim {}
            }

            Behavior on opacity {
                Anim {
                    type: Anim.DefaultEffects
                }
            }

            Behavior on scale {
                Anim {}
            }

            Behavior on x {
                Anim {}
            }
        }
    }

    Anim {
        id: contentYAnim

        target: root.container
        property: "contentY"
    }
}
