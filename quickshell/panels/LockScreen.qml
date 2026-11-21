import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../singletons"
import "../components"

WlSessionLockSurface {
    id: root

    color: "#000000"

    property string password: ""
    property bool authenticating: false
    property string error: ""
    property int tick: 0

    readonly property string wallpaperSource: Settings.data.wallpaper.length > 0
        ? "file://" + Utils.expand(Settings.data.wallpaper) : ""
    readonly property string avatarSource: {
        const u = Quickshell.env("USER") || "";
        const p = "/var/lib/AccountsService/icons/" + u;
        return p.length > 0 ? "file://" + p : "";
    }

    function tryUnlock() {
        if (root.authenticating)
            return;
        root.error = "";
        if (root.password.length === 0) {
            root.error = "Введите пароль";
            passwordInput.forceActiveFocus();
            return;
        }
        root.authenticating = true;
        if (!pam.start()) {
            root.authenticating = false;
            root.error = "Не удалось запустить PAM";
        }
    }

    function sendResponse() {
        if (root.password.length === 0)
            return;
        pam.respond(root.password);
        root.password = "";
        passwordInput.text = "";
    }

    function submit() {
        if (!root.authenticating)
            root.tryUnlock();
        else if (pam.responseRequired)
            root.sendResponse();
    }

    Timer { interval: 1000; repeat: true; running: true; onTriggered: root.tick++ }

    PamContext {
        id: pam
        config: "login"
        user: Quickshell.env("USER") || ""
        onResponseRequiredChanged: if (responseRequired) root.sendResponse()
        onCompleted: result => {
            root.authenticating = false;
            if (result === PamResult.Success) {
                root.password = ""; root.error = "";
                Ui.unlock();
            } else {
                root.error = "Неверный пароль";
                root.password = "";
                passwordInput.text = "";
                passwordInput.forceActiveFocus();
            }
        }
        onError: { root.authenticating = false; root.error = "Ошибка авторизации"; }
    }

    // Background ------------------------------------------------------------
    Image {
        id: bg
        anchors.fill: parent
        source: root.wallpaperSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Utils.alpha(Theme.bg, 0.20) }
            GradientStop { position: 0.45; color: Utils.alpha(Theme.bg, 0.45) }
            GradientStop { position: 1.0; color: Utils.alpha(Theme.bg, 0.78) }
        }
    }

    // Clock / date ----------------------------------------------------------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.12
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: { root.tick; return Utils.clockText(new Date(), Settings.data.use24h, false); }
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Math.min(112, root.height * 0.14)
            font.weight: Font.Light
            style: Text.Raised
            styleColor: Utils.alpha("#000000", 0.25)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Utils.dateText(new Date())
            color: Utils.alpha(Theme.text, 0.88)
            font.family: Theme.font
            font.pixelSize: 20
            style: Text.Raised
            styleColor: Utils.alpha("#000000", 0.2)
        }
    }

    // Center card -----------------------------------------------------------
    Rectangle {
        id: card
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.height * 0.06
        width: Math.min(420, root.width - 80)
        height: cardCol.implicitHeight + 44
        radius: Theme.radius + 8
        color: Utils.alpha(Theme.surface, 0.72)
        border.width: 1
        border.color: Utils.alpha(Theme.text, 0.08)

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: Utils.alpha(Theme.text, 0.04)
        }

        Column {
            id: cardCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 22
            spacing: 14

            // Avatar
            Item {
                width: 92; height: 92
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 46
                    color: Utils.alpha(Theme.accent, 0.18)
                    border.width: 2
                    border.color: Utils.alpha(Theme.accent, 0.45)
                }

                Image {
                    id: avatar
                    anchors.fill: parent
                    anchors.margins: 3
                    source: root.avatarSource
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                    layer.enabled: true
                    layer.effect: MultiEffect { maskEnabled: true; maskSource: avatarMask }
                }
                Item { id: avatarMask; anchors.fill: avatar; layer.enabled: true; visible: false; Rectangle { anchors.fill: parent; radius: width / 2 } }

                Icon {
                    anchors.centerIn: parent
                    visible: avatar.status !== Image.Ready
                    glyph: "\uf007"
                    size: 34
                    color: Theme.accent
                }
            }

            Text {
                width: parent.width
                text: Quickshell.env("USER") || "пользователь"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 22
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: root.authenticating ? "Проверка пароля…" : "Введите пароль для входа"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: Theme.radiusSmall
                color: Utils.alpha(Theme.text, passwordInput.activeFocus ? 0.09 : 0.05)
                border.width: 1
                border.color: passwordInput.activeFocus ? Utils.alpha(Theme.accent, 0.7) : Utils.alpha(Theme.text, 0.08)

                Icon {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf023"
                    size: 14
                    color: root.authenticating ? Theme.accent : Theme.subtext
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 42
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 15
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    passwordMaskDelay: 0
                    selectionColor: Utils.alpha(Theme.accent, 0.35)
                    selectedTextColor: Theme.text
                    clip: true
                    focus: true
                    enabled: !root.authenticating

                    onTextChanged: root.password = text
                    onAccepted: root.submit()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: passwordInput.text.length === 0
                        text: "Пароль"
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: 15
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.error.length > 0
                text: root.error
                color: Theme.red
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: Theme.radiusSmall
                color: unlockMouse.containsMouse ? Theme.accent : Utils.alpha(Theme.accent, 0.88)

                Text {
                    anchors.centerIn: parent
                    text: root.authenticating ? "Проверка..." : "Разблокировать"
                    color: Theme.onAccent
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: unlockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { passwordInput.forceActiveFocus(); root.submit(); }
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        text: "Enter — разблокировать"
        color: Utils.alpha(Theme.text, 0.55)
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
    }
}
