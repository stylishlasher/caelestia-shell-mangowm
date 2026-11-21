pragma Singleton
import QtQuick
import Quickshell
Singleton {
    property bool twelveHourClock: false
    function celsiusToFahrenheit(c){ return c*9/5+32; }
    function fahrenheitToCelsius(f){ return (f-32)*5/9; }
    function formatTemp(temp, compact){ 
        if (temp === undefined || temp === null || isNaN(temp)) return "";
        return Math.round(temp) + "°";
    }
}
