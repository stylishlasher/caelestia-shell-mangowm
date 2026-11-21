import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../singletons"
import "../components"

WlSessionLockSurface {
    id: root

    color: Theme.bg

    property string password: ""
    property bool authenticating: false
    property string error: ""
    property int tick: 0

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

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.tick++
    }

    PamContext {
        id: pam
        config: "login"
        user: Quickshell.env("USER") || ""

        onResponseRequiredChanged: {
            if (responseRequired)
                root.sendResponse();
        }

        onCompleted: result => {
            root.authenticating = false;
            if (result === PamResult.Success) {
                root.password = "";
                root.error = "";
                Ui.unlock();
            } else {
                root.error = "Неверный пароль";
                root.password = "";
                passwordInput.text = "";
                passwordInput.forceActiveFocus();
            }
        }

        onError: error => {
            root.authenticating = false;
            root.error = "Ошибка авторизации";
        }
    }

    Image {
        anchors.fill: parent
        source: Settings.data.wallpaper.length > 0
            ? "file://" + Utils.expand(Settings.data.wallpaper) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: source.toString().length > 0 && status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        color: Utils.alpha(Theme.bg, 0.72)
    }

    Column {
        anchors.centerIn: parent
        width: Math.min(420, parent.width - 64)
        spacing: 14

        Text {
            width: parent.width
            text: {
                root.tick;
                return Utils.clockText(new Date(), Settings.data.use24h, false);
            }
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 76
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            width: parent.width
            text: Utils.dateText(new Date())
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            horizontalAlignment: Text.AlignHCenter
            bottomPadding: 18
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 78
            height: 78
            radius: 39
            color: Utils.alpha(Theme.accent, 0.16)
            border.width: 2
            border.color: Utils.alpha(Theme.accent, 0.4)

            Icon {
                anchors.centerIn: parent
                glyph: "\uf033e"
                size: 30
                color: Theme.accent
            }
        }

        Text {
            width: parent.width
            text: Quickshell.env("USER") || "пользователь"
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            topPadding: 4
        }

        Rectangle {
            width: parent.width
            height: 46
            radius: Theme.radiusSmall
            color: Utils.alpha(Theme.text, 0.06)
            border.width: passwordInput.activeFocus ? 1 : 0
            border.color: Utils.alpha(Theme.accent, 0.5)

            Icon {
                id: lockIcon
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf033e"
                size: 14
                color: root.authenticating ? Theme.accent : Theme.subtext
            }

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                echoMode: TextInput.Password
                passwordCharacter: "●"
                passwordMaskDelay: 0
                selectionColor: Utils.alpha(Theme.accent, 0.4)
                selectedTextColor: Theme.text
                clip: true
                focus: true

                onTextChanged: root.password = text
                onAccepted: root.submit()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: passwordInput.text.length === 0
                    text: root.authenticating ? "Проверка пароля…" : "Пароль"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: 15
                }
            }
        }

        Text {
            width: parent.width
            text: root.error
            color: Theme.red
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            horizontalAlignment: Text.AlignHCenter
            visible: root.error.length > 0
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(220, parent.width)
            height: 42
            radius: Theme.radiusSmall
            color: unlockMouse.containsMouse
                ? Utils.alpha(Theme.accent, 0.32) : Utils.alpha(Theme.accent, 0.2)
            border.width: 1
            border.color: Utils.alpha(Theme.accent, 0.4)

            Row {
                anchors.centerIn: parent
                spacing: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf033e"
                    size: 13
                    color: Theme.accent
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.authenticating ? "Войти" : "Разблокировать"
                    color: Theme.accent
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                }
            }

            MouseArea {
                id: unlockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    passwordInput.forceActiveFocus();
                    root.submit();
                }
            }
        }

        Text {
            width: parent.width
            text: "Enter — разблокировать"
            color: Theme.subtext
            font.family: Theme.font
            font.pixelSize: Theme.fontTiny
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.7
            topPadding: 6
        }
    }
}
