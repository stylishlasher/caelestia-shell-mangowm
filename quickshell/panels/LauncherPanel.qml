import QtQuick
import Quickshell
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "launcher"
    preferredWidth: 620
    preferredHeight: 470

    property string query: ""
    property int selected: 0

    readonly property var allApps: DesktopEntries.applications.values || []

    readonly property var results: {
        const text = root.query.trim().toLowerCase();
        const source = root.allApps;
        const matched = [];

        for (let i = 0; i < source.length; i++) {
            const app = source[i];
            if (!app || app.noDisplay)
                continue;
            if (text.length === 0) {
                matched.push(app);
                continue;
            }
            const haystack = ((app.name || "") + " " + (app.genericName || "") + " "
                + (app.comment || "") + " " + (app.keywords || "") + " "
                + (app.execString || "")).toLowerCase();
            if (haystack.indexOf(text) !== -1)
                matched.push(app);
        }

        matched.sort((a, b) => {
            const an = String(a.name || "").toLowerCase();
            const bn = String(b.name || "").toLowerCase();
            if (text.length > 0) {
                const ap = an.indexOf(text) === 0 ? 0 : 1;
                const bp = bn.indexOf(text) === 0 ? 0 : 1;
                if (ap !== bp)
                    return ap - bp;
            }
            return an.localeCompare(bn);
        });

        return matched.slice(0, 60);
    }

    function currentApp() {
        return root.results.length > 0
            ? root.results[Math.max(0, Math.min(root.results.length - 1, root.selected))]
            : null;
    }

    function activate(app) {
        const target = app ? app : root.currentApp();
        if (!target)
            return;
        target.execute();
        Ui.close();
    }

    function move(delta) {
        if (root.results.length === 0)
            return;
        root.selected = (root.selected + delta + root.results.length) % root.results.length;
        appList.positionViewAtIndex(root.selected, ListView.Contain);
    }

    onQueryChanged: root.selected = 0

    Column {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            width: parent.width
            height: 50
            radius: Theme.radiusSmall
            color: Utils.alpha(Theme.text, 0.06)
            border.width: 1
            border.color: Utils.alpha(Theme.accent, 0.35)

            Icon {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf002"
                size: 16
                color: Theme.subtext
            }

            TextInput {
                id: searchInput
                anchors.left: searchIcon.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 16
                selectByMouse: true
                selectionColor: Utils.alpha(Theme.accent, 0.4)
                selectedTextColor: Theme.text
                focus: Ui.panel === "launcher"
                clip: true

                onTextChanged: root.query = text

                Keys.onDownPressed: root.move(1)
                Keys.onUpPressed: root.move(-1)
                Keys.onReturnPressed: root.activate(null)
                Keys.onEnterPressed: root.activate(null)
                Keys.onEscapePressed: Ui.close()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                    text: "Поиск приложений…"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: 16
                }
            }
        }

        Text {
            width: parent.width
            visible: root.query.length > 0
            height: visible ? implicitHeight : 0
            text: root.results.length + " результат(ов)"
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
        }

        ListView {
            id: appList
            width: parent.width
            height: parent.height - 50 - 12 - 36 - (root.query.length > 0 ? 26 : 0)
            clip: true
            model: root.results
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: appDelegate
                required property var modelData
                required property int index

                width: appList.width
                height: 48

                readonly property bool selected: appDelegate.index === root.selected

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: appDelegate.selected ? Utils.alpha(Theme.accent, 0.2)
                         : (appMouse.containsMouse ? Theme.hover : "transparent")

                    Behavior on color {
                        ColorAnimation { duration: Theme.durationFast }
                    }
                }

                AppIcon {
                    id: appIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: appDelegate.modelData.icon
                    size: 26
                }

                Column {
                    anchors.left: appIcon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        width: parent.width
                        text: appDelegate.modelData.name || appDelegate.modelData.id
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        visible: (appDelegate.modelData.genericName || appDelegate.modelData.comment || "").length > 0
                        text: appDelegate.modelData.genericName || appDelegate.modelData.comment || ""
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: appMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: root.selected = appDelegate.index
                    onClicked: root.activate(appDelegate.modelData)
                }
            }
        }

        Row {
            width: parent.width
            height: 30
            spacing: 8

            Repeater {
                model: [
                    { label: "Настройки", glyph: "\uf013", action: "settings" },
                    { label: "Обои", glyph: "\uf03e", action: "wallpaper" },
                    { label: "Блокировка", glyph: "\uf023", action: "lock" }
                ]

                Rectangle {
                    id: actionChip
                    required property var modelData
                    width: chipRow.implicitWidth + 20
                    height: 28
                    radius: 8
                    color: chipMouse.containsMouse ? Theme.hover : Utils.alpha(Theme.text, 0.05)

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: 6

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            glyph: actionChip.modelData.glyph
                            size: 12
                            color: Theme.subtext
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: actionChip.modelData.label
                            color: Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    MouseArea {
                        id: chipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (actionChip.modelData.action === "lock") {
                                Ui.close();
                                Ui.lock();
                            } else {
                                Ui.open(actionChip.modelData.action, root.screen ? root.screen.name : "");
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 1 }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter — запустить · Esc — закрыть"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
                opacity: 0.8
            }
        }
    }
}
