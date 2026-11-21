pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // Notifications that are currently shown as popups.
    property var popups: []
    // Tracked notifications for the control center history.
    property var tracked: []
    property int unread: 0
    property int revision: 0

    readonly property bool dnd: Settings.data.notificationsDnd

    function syncTracked() {
        const values = server.trackedNotifications ? server.trackedNotifications.values : [];
        root.tracked = values ? values.slice() : [];
        root.revision++;
    }

    function push(notification) {
        if (!notification)
            return;
        if (!root.dnd) {
            const entry = {
                notification: notification,
                time: Date.now()
            };
            root.popups = [entry].concat(root.popups).slice(0, 4);
            root.unread++;
        }
    }

    function remove(notification) {
        const next = [];
        for (let i = 0; i < root.popups.length; i++) {
            if (root.popups[i].notification !== notification)
                next.push(root.popups[i]);
        }
        root.popups = next;
    }

    function prune() {
        const now = Date.now();
        const next = [];
        for (let i = 0; i < root.popups.length; i++) {
            const entry = root.popups[i];
            const timeout = entry.notification && entry.notification.expireTimeout > 0
                ? entry.notification.expireTimeout : 6000;
            if (now - entry.time < timeout + 300)
                next.push(entry);
        }
        if (next.length !== root.popups.length)
            root.popups = next;
    }

    function dismiss(notification) {
        if (!notification)
            return;
        try {
            notification.dismiss();
        } catch (e) {
        }
        root.remove(notification);
    }

    function dismissAll() {
        const list = root.tracked || [];
        for (let i = 0; i < list.length; i++) {
            try {
                list[i].dismiss();
            } catch (e) {
            }
        }
        root.popups = [];
        root.tracked = [];
        root.unread = 0;
    }

    function markRead() {
        root.unread = 0;
    }

    function toggleDnd() {
        Settings.data.notificationsDnd = !Settings.data.notificationsDnd;
        if (Settings.data.notificationsDnd)
            root.dismissAll();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        inlineReplySupported: true

        onNotification: notification => root.push(notification)
    }

    Connections {
        target: server.trackedNotifications
        function onValuesChanged() {
            root.syncTracked();
        }
    }

    Component.onCompleted: syncTracked()

    Timer {
        interval: 1000
        repeat: true
        running: root.popups.length > 0
        onTriggered: root.prune()
    }
}
