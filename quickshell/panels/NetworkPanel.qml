import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "network"
    preferredWidth: 480
    preferredHeight: 580

    property var pendingNetwork: null
    property string password: ""
    property string netError: ""

    readonly property var wifiDevice: {
        const devices = Networking.devices.values || [];
        for (let i = 0; i < devices.length; i++) {
            if (devices[i] && devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    readonly property var wifiNetworks: {
        const source = root.wifiDevice ? (root.wifiDevice.networks.values || []) : [];
        const list = [];
        for (let i = 0; i < source.length; i++) {
            if (source[i])
                list.push(source[i]);
        }
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            return (b.signalStrength || 0) - (a.signalStrength || 0);
        });
        return list;
    }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var btDevices: {
        const source = root.adapter ? (root.adapter.devices.values || []) : [];
        const list = [];
        for (let i = 0; i < source.length; i++) {
            if (source[i] && (source[i].paired || source[i].connected || source[i].name))
                list.push(source[i]);
        }
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            return String(a.name || "").localeCompare(String(b.name || ""));
        });
        return list;
    }

    function isSecured(network) {
        return network.security !== WifiSecurityType.Open
            && network.security !== WifiSecurityType.Unknown;
    }

    function chooseNetwork(network) {
        root.netError = "";
        if (network.connected) {
            network.disconnect();
            return;
        }
        if (root.isSecured(network) && !network.known) {
            root.pendingNetwork = network;
            root.password = "";
            return;
        }
        network.connect();
    }

    function submitPassword() {
        if (!root.pendingNetwork)
            return;
        root.pendingNetwork.connectWithPsk(root.password);
        root.pendingNetwork = null;
        root.password = "";
    }

    function strengthGlyph() {
        return "\uf05a9";
    }

    Flickable {
        anchors.fill: parent
        clip: true
        contentHeight: body.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: body
            width: parent.width - 6
            spacing: 2

            Row {
                width: parent.width
                spacing: 10
                bottomPadding: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf05a9"
                    size: 18
                    color: Theme.accent
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Сеть и Bluetooth"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.fontLarge
                    font.weight: Font.DemiBold
                }
            }

            SettingRow {
                title: "Wi-Fi"
                description: root.wifiDevice
                    ? (Networking.wifiEnabled ? "Включён" : "Выключен")
                    : "Адаптер не найден"
                ToggleSwitch {
                    checked: Networking.wifiEnabled
                    available: root.wifiDevice !== null
                    onToggled: value => Networking.wifiEnabled = value
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Utils.alpha(Theme.text, 0.06)
                anchors.topMargin: 4
            }

            Column {
                width: parent.width
                height: visible ? implicitHeight : 0
                visible: Networking.wifiEnabled
                spacing: 1
                topPadding: 6

                Text {
                    visible: root.wifiNetworks.length === 0
                    text: "Сети не найдены…"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    topPadding: 8
                }

                Repeater {
                    model: Networking.wifiEnabled ? root.wifiNetworks : []

                    Item {
                        id: networkRow
                        required property var modelData

                        width: body.width
                        height: 44

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusSmall
                            color: netMouse.containsMouse ? Theme.hover : "transparent"
                            border.width: networkRow.modelData.connected ? 1 : 0
                            border.color: Utils.alpha(Theme.accent, 0.3)
                        }

                        Icon {
                            id: netIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            glyph: root.strengthGlyph()
                            size: 15
                            color: networkRow.modelData.connected ? Theme.accent : Theme.subtext
                            opacity: 0.45 + 0.55 * Math.min(1, (networkRow.modelData.signalStrength || 0) / 100)
                        }

                        Column {
                            anchors.left: netIcon.right
                            anchors.leftMargin: 10
                            anchors.right: netRight.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                width: parent.width
                                text: networkRow.modelData.name || "—"
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                font.weight: networkRow.modelData.connected ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: {
                                    const parts = [];
                                    if (networkRow.modelData.connected)
                                        parts.push("подключено");
                                    if (root.isSecured(networkRow.modelData))
                                        parts.push("защищено");
                                    if (!parts.length)
                                        parts.push("открытая сеть");
                                    return parts.join(" · ");
                                }
                                color: networkRow.modelData.connected ? Theme.accent : Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontTiny
                            }
                        }

                        Row {
                            id: netRight
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: root.isSecured(networkRow.modelData)
                                glyph: "\uf033e"
                                size: 11
                                color: Theme.subtext
                            }

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: networkRow.modelData.connected
                                glyph: "\uf012c"
                                size: 12
                                color: Theme.accent
                            }
                        }

                        MouseArea {
                            id: netMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.chooseNetwork(networkRow.modelData)
                        }
                    }
                }
            }

            Column {
                width: parent.width
                height: visible ? implicitHeight : 0
                visible: root.pendingNetwork !== null
                spacing: 6
                topPadding: 8

                Text {
                    text: "Пароль для «" + (root.pendingNetwork ? root.pendingNetwork.name : "") + "»"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }

                Row {
                    spacing: 8

                    Field {
                        width: 280
                        placeholder: "Пароль Wi-Fi"
                        echoMode: TextInput.Password
                        onTextChanged: root.password = text
                        onAccepted: root.submitPassword()
                    }

                    Chip {
                        label: "Подключить"
                        active: true
                        onClicked: root.submitPassword()
                    }

                    Chip {
                        label: "Отмена"
                        onClicked: {
                            root.pendingNetwork = null;
                            root.password = "";
                        }
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.netError.length > 0
                height: visible ? implicitHeight : 0
                text: root.netError
                color: Theme.red
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
                topPadding: 6
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 8 }

            Rectangle {
                width: parent.width
                height: 1
                color: Utils.alpha(Theme.text, 0.06)
            }

            Item { width: 1; height: 8 }

            Row {
                width: parent.width
                spacing: 10
                bottomPadding: 6

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf00af"
                    size: 17
                    color: Theme.accent
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }

                Item { width: 1; height: 1 }

                Chip {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.adapter !== null
                    label: root.adapter && root.adapter.discovering ? "Поиск…" : "Поиск устройств"
                    glyph: "\uf0349"
                    active: root.adapter && root.adapter.discovering
                    onClicked: {
                        if (root.adapter)
                            root.adapter.discovering = !root.adapter.discovering;
                    }
                }
            }

            SettingRow {
                title: "Адаптер"
                description: root.adapter
                    ? (root.adapter.enabled ? "Включён" : "Выключен")
                    : "Не найден"
                ToggleSwitch {
                    checked: root.adapter ? root.adapter.enabled : false
                    available: root.adapter !== null
                    onToggled: value => {
                        if (root.adapter)
                            root.adapter.enabled = value;
                    }
                }
            }

            Text {
                visible: root.adapter === null
                text: "Bluetooth-адаптер не обнаружен"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                topPadding: 6
            }

            Column {
                width: parent.width
                height: visible ? implicitHeight : 0
                visible: root.adapter !== null && root.adapter.enabled
                spacing: 1
                topPadding: 4

                Text {
                    visible: root.btDevices.length === 0
                    text: "Устройства не найдены"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    topPadding: 6
                }

                Repeater {
                    model: root.adapter && root.adapter.enabled ? root.btDevices : []

                    Item {
                        id: btRow
                        required property var modelData

                        width: body.width
                        height: 44

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusSmall
                            color: btMouse.containsMouse ? Theme.hover : "transparent"
                        }

                        Icon {
                            id: btIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            glyph: "\uf00af"
                            size: 15
                            color: btRow.modelData.connected ? Theme.accent : Theme.subtext
                        }

                        Column {
                            anchors.left: btIcon.right
                            anchors.leftMargin: 10
                            anchors.right: btRight.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                width: parent.width
                                text: btRow.modelData.name || btRow.modelData.address
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                font.weight: btRow.modelData.connected ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: btRow.modelData.connected
                                    ? "подключено"
                                    : (btRow.modelData.paired ? "в паре" : "доступно")
                                color: btRow.modelData.connected ? Theme.accent : Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontTiny
                            }
                        }

                        Row {
                            id: btRight
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: btRow.modelData.batteryAvailable
                                text: Math.round(btRow.modelData.battery) + "%"
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontTiny
                            }

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: btRow.modelData.connected
                                glyph: "\uf012c"
                                size: 12
                                color: Theme.accent
                            }
                        }

                        MouseArea {
                            id: btMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const device = btRow.modelData;
                                if (device.connected) {
                                    device.disconnect();
                                } else if (device.paired) {
                                    device.connect();
                                } else {
                                    device.pair();
                                }
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 14 }
        }
    }
}
