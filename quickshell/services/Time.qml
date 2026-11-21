pragma Singleton

import QtQuick
import Quickshell
import Caelestia.I18n
import qs.utils

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date || new Date()
    readonly property int hours: clock.hours || 0
    readonly property int minutes: clock.minutes || 0
    readonly property int seconds: clock.seconds || 0

    readonly property string timeStr: format(Units.twelveHourClock ? "hh:mm:A" : "hh:mm")
    readonly property list<string> timeComponents: timeStr.split(":")
    readonly property string hourStr: timeComponents[0] ?? ""
    readonly property string minuteStr: timeComponents[1] ?? ""
    readonly property string amPmStr: timeComponents[2] ?? ""

    function format(fmt: string): string {
        return Tr.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }
}
