pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string loc
    property string city
    property string icon
    property string description
    property string tempC: "0°C"
    property string tempF: "0°F"

    function reload(): void {
        if (Config.data.weatherLocation)
            loc = Config.data.weatherLocation;
        else if (!loc || timer.elapsed() > 900)
            Requests.get("https://ipinfo.io/json", text => {
                const json = JSON.parse(text);
                loc = json.loc ?? "";
                city = json.city;
                timer.restart();
            });
    }

    IpcHandler {
        target: "weather"

        function fetch() {
            root.fetchWeather();
        }
    }

    function fetchWeather() {
        Requests.get(`https://wttr.in/${city}?format=j1`, text => {
            const json = JSON.parse(text).current_condition[0];
            icon = Icons.getWeatherIcon(json.weatherCode);
            description = json.weatherDesc[0].value;
            tempC = `${parseFloat(json.temp_C)}°C`;
            tempF = `${parseFloat(json.temp_F)}°F`;
        });
    }

    onLocChanged: fetchWeather()
    Component.onCompleted: reload()

    ElapsedTimer {
        id: timer
    }
}
