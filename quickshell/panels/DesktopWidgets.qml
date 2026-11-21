import QtQuick
import Quickshell
import Quickshell.Wayland
import "../singletons"
import "../components"

Scope {
    id: root

    property var modelData: null
    property bool editMode: false
    readonly property string screenName: modelData ? String(modelData.name) : ""

    Connections {
        target: Ui
        function onDesktopEditRequestChanged() { root.editMode = true; editHideTimer.restart(); }
    }
    Timer { id: editHideTimer; interval: 8000; onTriggered: root.editMode = false }
    readonly property bool isMainScreen: {
        if (Quickshell.screens.length === 0)
            return true;
        if (Mango.ready && Mango.focusedName.length > 0)
            return Mango.focusedName === root.screenName;
        return Quickshell.screens[0].name === root.screenName;
    }

    readonly property bool posTop: Settings.data.desktopWidgetPosition.indexOf("top") === 0
    readonly property bool posLeft: Settings.data.desktopWidgetPosition.indexOf("left") !== -1
    readonly property int baseMargin: (Settings.data.barEnabled && Settings.data.barPosition === "top" && posTop)
        ? Theme.barHeight + 18 : 18
    readonly property int bottomMargin: (Settings.data.barEnabled && Settings.data.barPosition === "bottom" && !posTop)
        ? Theme.barHeight + 18 : 18

    // Clock & weather widget ------------------------------------------------
    PanelWindow {
        id: clockWindow
        screen: root.modelData
        visible: (Settings.data.showDesktopClock || Settings.data.showDesktopWeather) && !Ui.locked
        color: "transparent"
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        implicitWidth: clockCard.implicitWidth
        implicitHeight: clockCard.implicitHeight

        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "stylish-desktop-clock"

        Timer { id: clockRightClickTimer; interval: 350 }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                if (clockRightClickTimer.running) { clockRightClickTimer.stop(); Ui.open("settings", root.screenName); Ui.desktopEditRequest++; }
                else clockRightClickTimer.restart();
            }
            z: -1
        }

        anchors {
            top: root.posTop
            bottom: !root.posTop
            left: root.posLeft
            right: !root.posLeft
        }

        margins {
            top: root.posTop ? root.baseMargin : 0
            bottom: !root.posTop ? root.bottomMargin : 0
            left: root.posLeft ? 18 : 0
            right: !root.posLeft ? 18 : 0
        }

        Rectangle {
            visible: root.editMode
            anchors.bottom: clockCard.top
            anchors.horizontalCenter: clockCard.horizontalCenter
            anchors.bottomMargin: 8
            width: hintText.implicitWidth + 20
            height: 30
            radius: 8
            color: Theme.panelColor
            border.width: 1
            border.color: Theme.border
            z: 99
            Text { id: hintText; anchors.centerIn: parent; text: "Двойной ПКМ по рабочему столу — редактор виджетов (вкладка Виджеты)"; color: Theme.text; font.family: Theme.font; font.pixelSize: Theme.fontTiny }
        }

        Rectangle {
            id: clockCard
            implicitWidth: clockCol.implicitWidth + 36
            implicitHeight: clockCol.implicitHeight + 28
            radius: Theme.radius + 6
            color: Utils.alpha(Theme.surface, Math.max(0.18, Settings.data.panelOpacity * 0.55))
            border.width: 1
            border.color: Utils.alpha(Theme.text, 0.08)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: "transparent"
                border.width: 1
                border.color: Utils.alpha(Theme.accent, 0.10)
            }

            Column {
                id: clockCol
                anchors.centerIn: parent
                spacing: 6

                SystemClock {
                    id: deskClock
                    precision: Settings.data.showSeconds ? SystemClock.Seconds : SystemClock.Minutes
                }

                Text {
                    visible: Settings.data.showDesktopClock
                    text: Utils.clockText(deskClock.date, Settings.data.use24h, Settings.data.showSeconds)
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 52
                    font.weight: Font.Light
                    horizontalAlignment: root.posLeft ? Text.AlignLeft : Text.AlignRight
                }

                Text {
                    visible: Settings.data.showDesktopClock
                    text: Utils.dateText(deskClock.date)
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    horizontalAlignment: root.posLeft ? Text.AlignLeft : Text.AlignRight
                }

                Rectangle {
                    visible: Settings.data.showDesktopClock && Settings.data.showDesktopWeather && Weather.hasData
                    width: parent.implicitWidth
                    height: 1
                    color: Utils.alpha(Theme.text, 0.10)
                    opacity: 0.8
                }

                Row {
                    visible: Settings.data.showDesktopWeather
                    spacing: 10
                    layoutDirection: root.posLeft ? Qt.LeftToRight : Qt.RightToLeft
                    anchors.horizontalCenter: parent.horizontalCenter

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        glyph: Weather.hasData ? Utils.weatherIcon(Weather.weatherCode, Weather.isDay) : "\uf0c2"
                        size: 28
                        color: Theme.accent
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Text {
                            text: Weather.hasData
                                ? (Weather.temperatureText(Weather.temperature) + " · " + Utils.weatherText(Weather.weatherCode))
                                : (Weather.loading ? "Загрузка погоды…" : (Weather.error.length > 0 ? Weather.error : "Погода недоступна"))
                            color: Weather.error.length > 0 ? Theme.red : Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.Medium
                        }

                        Text {
                            visible: Weather.hasData
                            text: (Weather.place || Settings.data.weatherCity)
                                + " · ощущается " + Weather.temperatureText(Weather.feelsLike)
                            color: Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: Ui.toggle("time", root.screenName)
            }
        }
    }

    // Media widget ----------------------------------------------------------
    PanelWindow {
        id: mediaWindow
        screen: root.modelData
        visible: Settings.data.showDesktopMedia && Media.hasPlayer && !Ui.locked
        color: "transparent"
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        implicitWidth: 340
        implicitHeight: mediaCard.implicitHeight

        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "stylish-desktop-media"

        Timer { id: mediaRightClickTimer; interval: 350 }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                if (mediaRightClickTimer.running) { mediaRightClickTimer.stop(); Ui.open("settings", root.screenName); Ui.desktopEditRequest++; }
                else mediaRightClickTimer.restart();
            }
            z: -1
        }

        anchors {
            bottom: true
            left: root.posLeft
            right: !root.posLeft
        }

        margins {
            bottom: root.bottomMargin + (Settings.data.dockEnabled && !root.posTop ? Theme.dockHeight + 10 : 0)
            left: root.posLeft ? 18 : 0
            right: !root.posLeft ? 18 : 0
        }

        Rectangle {
            id: mediaCard
            width: mediaWindow.implicitWidth
            implicitHeight: mediaCol.implicitHeight + 20
            radius: Theme.radius + 4
            color: Utils.alpha(Theme.surface, Math.max(0.18, Settings.data.panelOpacity * 0.55))
            border.width: 1
            border.color: Utils.alpha(Theme.text, 0.08)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: "transparent"
                border.width: 1
                border.color: Utils.alpha(Theme.accent, 0.10)
            }

            Column {
                id: mediaCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        width: 64
                        height: 64
                        radius: Theme.radiusSmall
                        color: Utils.alpha(Theme.text, 0.06)
                        clip: true

                        Image {
                            id: art
                            anchors.fill: parent
                            source: Media.artUrl
                            sourceSize.width: 128
                            sourceSize.height: 128
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: status === Image.Ready && Media.artUrl.length > 0
                        }

                        Icon {
                            anchors.centerIn: parent
                            visible: art.status !== Image.Ready || Media.artUrl.length === 0
                            glyph: "\uf001"
                            size: 22
                            color: Utils.alpha(Theme.subtext, 0.7)
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 76
                        spacing: 2

                        Text {
                            width: parent.width
                            text: Media.title.length > 0 ? Media.title : (Media.identity || "Медиа")
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            visible: Media.artist.length > 0 || Media.album.length > 0
                            text: [Media.artist, Media.album].filter(function(x){ return x && x.length; }).join(" · ")
                            color: Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                            elide: Text.ElideRight
                        }

                        Text {
                            text: Media.playing ? "Воспроизводится" : "Пауза"
                            color: Media.playing ? Theme.accent : Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Utils.alpha(Theme.text, 0.10)

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, Media.position() / Math.max(1, Media.length || 1)))
                        height: parent.height
                        radius: parent.radius
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic }
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    IconButton {
                        glyph: "\uf048"
                        iconSize: 14
                        onClicked: Media.previous()
                    }
                    IconButton {
                        glyph: Media.playing ? "\uf04c" : "\uf04b"
                        iconSize: 15
                        active: Media.playing
                        onClicked: Media.toggle()
                    }
                    IconButton {
                        glyph: "\uf051"
                        iconSize: 14
                        onClicked: Media.next()
                    }
                    IconButton {
                        glyph: "\uf001"
                        iconSize: 13
                        onClicked: Ui.toggle("music", root.screenName)
                    }
                }
            }
        }
    }
}
