import QtQuick
import Quickshell
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "time"
    preferredWidth: 540
    preferredHeight: 580

    property int tick: 0

    readonly property var daily: Weather.daily
    readonly property int forecastDays: {
        if (!root.daily || !root.daily.time)
            return 0;
        return Math.min(5, root.daily.time.length);
    }

    function dayLabel(index) {
        if (!root.daily || !root.daily.time || index >= root.daily.time.length)
            return "";
        const date = new Date(root.daily.time[index] + "T12:00:00");
        if (isNaN(date.getTime()))
            return "";
        return Utils.weekdayShort(date.getDay());
    }

    function sunTime(value) {
        if (!value)
            return "—";
        const text = String(value);
        return text.length >= 16 ? text.slice(11, 16) : text;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.tick++
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
                bottomPadding: 6

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: {
                            root.tick;
                            return Utils.clockText(new Date(), Settings.data.use24h, true);
                        }
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 46
                        font.weight: Font.Light
                    }

                    Text {
                        text: Utils.dateText(new Date())
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                }

                Item { width: 1; height: 1 }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf021"
                    iconSize: 14
                    tint: Theme.subtext
                    onClicked: Weather.refresh()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "\uf00d"
                    iconSize: 13
                    tint: Theme.subtext
                    onClicked: Ui.close()
                }
            }

            // Current conditions ---------------------------------------------
            Rectangle {
                width: parent.width
                height: 152
                radius: Theme.radius
                color: Utils.alpha(Theme.accent, 0.10)
                border.width: 1
                border.color: Utils.alpha(Theme.accent, 0.18)

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: Weather.hasData ? Weather.place : Settings.data.weatherCity
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: Weather.hasData
                            ? Weather.temperatureText(Weather.temperature) : "—"
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 54
                        font.weight: Font.Light
                    }

                    Text {
                        text: Weather.hasData
                            ? (Utils.weatherText(Weather.weatherCode)
                                + " · ощущается " + Weather.temperatureText(Weather.feelsLike))
                            : (Weather.loading ? "Загрузка…" : (Weather.error.length > 0
                                ? Weather.error : "Нет данных"))
                        color: Weather.error.length > 0 ? Theme.red : Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                    }
                }

                Icon {
                    anchors.right: parent.right
                    anchors.rightMargin: 22
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Weather.hasData
                    glyph: Utils.weatherIcon(Weather.weatherCode, Weather.isDay)
                    size: 74
                    color: Theme.accent
                }
            }

            // Details --------------------------------------------------------
            Row {
                width: parent.width
                spacing: 8
                topPadding: 10

                Repeater {
                    model: [
                        { label: "Влажность", value: Weather.hasData ? Weather.humidity + "%" : "—",
                          glyph: "\uf072" },
                        { label: "Ветер", value: Weather.hasData
                            ? (Weather.windText(Weather.windSpeed) + " " + Utils.windDir(Weather.windDirection))
                            : "—", glyph: "\uf043" },
                        { label: "Рассвет", value: root.daily && root.daily.sunrise
                            ? root.sunTime(root.daily.sunrise[0]) : "—", glyph: "\uf185" },
                        { label: "Закат", value: root.daily && root.daily.sunset
                            ? root.sunTime(root.daily.sunset[0]) : "—", glyph: "\uf186" }
                    ]

                    Rectangle {
                        id: detailCard
                        required property var modelData

                        width: (body.width - 24) / 4
                        height: 68
                        radius: Theme.radiusSmall
                        color: Utils.alpha(Theme.text, 0.04)

                        Column {
                            anchors.centerIn: parent
                            spacing: 3

                            Icon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                glyph: detailCard.modelData.glyph
                                size: 14
                                color: Theme.accent
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: detailCard.modelData.value
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                                font.weight: Font.Medium
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: detailCard.modelData.label
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: 9
                            }
                        }
                    }
                }
            }

            // Forecast -------------------------------------------------------
            Text {
                text: "ПРОГНОЗ"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
                font.letterSpacing: 1.4
                font.weight: Font.DemiBold
                topPadding: 16
                bottomPadding: 6
            }

            Column {
                width: parent.width
                spacing: 3

                Repeater {
                    model: root.forecastDays

                    Rectangle {
                        id: forecastRow
                        required property int index
                        required property var modelData

                        width: body.width
                        height: 46
                        radius: Theme.radiusSmall
                        color: Utils.alpha(Theme.text, 0.035)

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            width: 50
                            text: root.dayLabel(forecastRow.index)
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                            font.weight: Font.DemiBold
                        }

                        Icon {
                            anchors.left: parent.left
                            anchors.leftMargin: 70
                            anchors.verticalCenter: parent.verticalCenter
                            glyph: Utils.weatherIcon(root.daily.weather_code[forecastRow.index], true)
                            size: 16
                            color: Theme.accent
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 102
                            anchors.right: tempText.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: Utils.weatherText(root.daily.weather_code[forecastRow.index])
                            color: Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontTiny
                            elide: Text.ElideRight
                        }

                        Text {
                            id: tempText
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: Weather.temperatureText(root.daily.temperature_2m_min[forecastRow.index])
                                + " / " + Weather.temperatureText(root.daily.temperature_2m_max[forecastRow.index])
                            color: Theme.text
                            font.family: Theme.mono
                            font.pixelSize: Theme.fontSmall
                        }
                    }
                }

                Text {
                    width: parent.width
                    visible: root.forecastDays === 0
                    text: Weather.loading ? "Загрузка прогноза…" : "Прогноз недоступен"
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    topPadding: 4
                }
            }

            Item { width: 1; height: 12 }
        }
    }
}
