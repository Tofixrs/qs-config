pragma Singleton

import QtQuick 2.15
import QtQuick.Layouts
import qs.config
import qs.services
import Quickshell

Singleton {
	id: root

	property string lastLocation: ""
	property var latestPayload: null
	property var currentCondition: null
	property var dailyForecast: []
	property var weatherAlerts: []
	property bool loading: false
	property string error: ""
	readonly property string currentTemp: currentCondition ? currentCondition.temp_C : ""
	readonly property string currentIcon: Icons.weatherIcons[currentCondition ? currentCondition.weatherCode : 113]

	signal updated
	signal failed(string reason)

	Timer {
		interval: 600000
		running: true
		repeat: true
		onTriggered: root.refreshCurrent()
	}

	function _buildUrl(location, options) {
		const base = "https://wttr.in/";
		const loc = encodeURIComponent((location && location.trim()) || "MyLocation");
		const params = ["format=j1", "m", "Q"]; // j1 JSON, metric units, quiet output
		if (options) {
			if (options.lang)
				params.push("lang=" + encodeURIComponent(options.lang));
			if (options.units)
				params.push("u=" + encodeURIComponent(options.units));
			if (options.theme)
				params.push("theme=" + encodeURIComponent(options.theme));
		}
		return base + loc + "?" + params.join("&");
	}

	function refresh(location, options) {
		const url = root._buildUrl(location || root.lastLocation || "MyLocation", options);
		root.loading = true;
		root.error = "";
		const request = new XMLHttpRequest();
		request.onreadystatechange = function () {
			if (request.readyState !== XMLHttpRequest.DONE)
				return;
			root.loading = false;
			if (request.status === 200) {
				try {
					const payload = JSON.parse(request.responseText);
					root.latestPayload = payload;
					root.currentCondition = payload.current_condition ? payload.current_condition[0] : null;
					root.dailyForecast = payload.weather || [];
					root.weatherAlerts = payload.alerts || [];
					root.lastLocation = location || root.lastLocation || "MyLocation";
					root.updated();
				} catch (err) {
					root.error = err.toString();
					root.failed(root.error);
				}
			} else {
				root.error = "HTTP " + request.status;
				root.failed(root.error);
			}
		};
		request.open("GET", url);
		request.setRequestHeader("Accept", "application/json");
		request.send();
	}

	function refreshCurrent(options) {
		refresh(root.lastLocation || "MyLocation", options);
	}
}
