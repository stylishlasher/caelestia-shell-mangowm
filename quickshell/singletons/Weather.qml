pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string city: Settings.data.weatherCity
    readonly property bool metric: Settings.data.weatherMetric

    property bool loading: false
    property string error: ""
    property string place: ""
    property real latitude: NaN
    property real longitude: NaN
    property var current: null
    property var daily: null
    property var updated: null

    readonly property bool hasData: current !== null
    readonly property real temperature: current ? current.temperature_2m : 0
    readonly property real feelsLike: current ? current.apparent_temperature : 0
    readonly property int humidity: current ? current.relative_humidity_2m : 0
    readonly property int windSpeed: current ? current.wind_speed_10m : 0
    readonly property int windDirection: current ? current.wind_direction_10m : 0
    readonly property int weatherCode: current ? current.weather_code : 0
    readonly property bool isDay: current ? current.is_day === 1 : true

    function unit(value) {
        return Math.round(Number(value) || 0);
    }

    function temperatureText(value) {
        const number = root.unit(value);
        return root.metric ? (number + "°") : (Math.round(number * 9 / 5 + 32) + "°");
    }

    function windText(value) {
        const number = Math.round(Number(value) || 0);
        return root.metric ? (number + " км/ч") : (Math.round(number * 0.621) + " mph");
    }

    function refresh() {
        if (!root.city || root.city.length === 0)
            return;
        root.loading = true;
        root.error = "";
        geoProcess.running = false;
        geoProcess.command = [
            "curl", "-fsS", "--max-time", "12", "--get",
            "--data-urlencode", "name=" + root.city,
            "--data", "count=1&language=ru&format=json",
            "https://geocoding-api.open-meteo.com/v1/search"
        ];
        geoProcess.running = true;
    }

    function fetchForecast() {
        if (isNaN(root.latitude) || isNaN(root.longitude))
            return;
        forecastProcess.running = false;
        forecastProcess.command = [
            "curl", "-fsS", "--max-time", "12", "--get",
            "--data", "latitude=" + root.latitude + "&longitude=" + root.longitude
                + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,"
                + "precipitation,weather_code,wind_speed_10m,wind_direction_10m"
                + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,"
                + "precipitation_probability_max&timezone=auto&forecast_days=5",
            "https://api.open-meteo.com/v1/forecast"
        ];
        forecastProcess.running = true;
    }

    Process {
        id: geoProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    if (!parsed.results || parsed.results.length === 0) {
                        root.error = "Город не найден";
                        root.loading = false;
                        return;
                    }
                    const result = parsed.results[0];
                    root.place = result.name || root.city;
                    root.latitude = result.latitude;
                    root.longitude = result.longitude;
                    root.fetchForecast();
                } catch (e) {
                    root.error = "Не удалось определить город";
                    root.loading = false;
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.loading) {
                root.error = "Нет подключения к интернету";
                root.loading = false;
            }
        }
    }

    Process {
        id: forecastProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    root.current = parsed.current || null;
                    root.daily = parsed.daily || null;
                    root.updated = new Date();
                    root.loading = false;
                    root.error = "";
                } catch (e) {
                    root.error = "Не удалось загрузить погоду";
                    root.loading = false;
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.loading) {
                root.error = "Нет подключения к интернету";
                root.loading = false;
            }
        }
    }

    Timer {
        interval: Math.max(5, Number(Settings.data.weatherRefreshMinutes) || 15) * 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    onCityChanged: refresh()

    Component.onCompleted: refresh()
}
