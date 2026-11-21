import QtQuick
import Caelestia.Config
import qs.services

StyledText {
    id: root
    property real fill
    property int grade: Colours.light ? 0 : -25
    property var fontStyle: Tokens.font.icon.small

    // fallback mapping for systems without Material Symbols Rounded
    readonly property var _fallback: ({
        "calendar_month":"󰃭","schedule":"","power_settings_new":"⏻","wifi":"","wifi_off":"󰖪",
        "bluetooth":"","battery_full":"","battery_android_full":"","volume_up":"","volume_off":"",
        "settings":"","search":"","close":"","menu":"","dashboard":"","cloud":"",
        "speed":"","queue_music":"","desktop_windows":"","notifications":"","lock":"",
        "image":"","palette":"","dark_mode":"","light_mode":"","bedtime":"","cached":"",
        "exit_to_app":"","calculate":"","casino":"","colors":"","opacity":""
    })

    function _mkFont() {
        const fs = fontStyle || Tokens.font.icon.small;
        const pt = fs && fs.pointSize ? fs.pointSize : 16;
        const fam = fs && fs.family ? fs.family : "Material Symbols Rounded";
        // Use Nerd Font if Material Symbols not available
        const hasMS = Qt.fontFamilies().includes("Material Symbols Rounded") || Qt.fontFamilies().includes("Material Symbols Outlined");
        const family = hasMS ? "Material Symbols Rounded" : "JetBrainsMono Nerd Font";
        return Qt.font({ family: family, pointSize: pt });
    }

    text: {
        const hasMS = Qt.fontFamilies().includes("Material Symbols Rounded") || Qt.fontFamilies().includes("Material Symbols Outlined");
        if (!hasMS && _fallback[root.text]) return _fallback[root.text];
        return root.text;
    }
    font: _mkFont()
}
