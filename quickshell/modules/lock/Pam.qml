pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

Scope {
    id: root

    enum PamState { None, Error, MaxTries, Failed }

    required property WlSessionLock lock

    readonly property alias passwd: passwd
    property QtObject fprint: QtObject { property bool active: false; property bool canAttempt: false; property int tries: 0; property int errorCount: 0; property int state: 0; signal completed(string state, string msg); function start(){} function abort(){} function reset(){} }
    property QtObject face: QtObject { property bool active: false; property bool canAttempt: false; property int tries: 0; property int errorCount: 0; property int state: 0; signal completed(string state, string msg); function start(){} function abort(){} function reset(){} }

    property string lockMessage: ""
    property int state: Pam.PamState.None
    property string buffer: ""

    signal flashMsg()

    function handleKey(event) {
        if (passwd.active) return;
        if (state === Pam.PamState.MaxTries) return;
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            passwd.start();
        } else if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_U) && (event.modifiers & Qt.ControlModifier)) {
            buffer = "";
        } else if (event.key === Qt.Key_Backspace) {
            buffer = buffer.slice(0, -1);
        } else if (/^[^\x00-\x1F\x7F-\x9F]+$/.test(event.text)) {
            buffer += event.text;
        }
    }

    function restartFprint() {}
    function clearTransientState() { root.state = Pam.PamState.None; root.lockMessage = ""; }

    PamContext {
        id: passwd
        config: "login"

        onResponseRequiredChanged: {
            if (responseRequired) {
                respond(root.buffer);
                root.buffer = "";
            }
        }
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.lock.locked = false;
            } else {
                root.state = Pam.PamState.Error;
                root.lockMessage = "Authentication failed";
                root.flashMsg();
            }
        }
    }
}
