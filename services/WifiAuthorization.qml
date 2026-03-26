pragma Singleton

import QtQuick
import qs.services
import qs.config
import Quickshell

Singleton {
	id: root

	property bool visible: false
	property string ssid: ""
	property string bssid: ""
	property string password: ""
	property string error: ""
	property bool working: false

	function open(targetSsid, targetBssid) {
		root.ssid = targetSsid || "";
		root.bssid = targetBssid || "";
		root.password = "";
		root.error = "";
		root.working = false;
		root.visible = true;
	}

	function close() {
		root.visible = false;
		root.working = false;
	}

	function submit() {
		if (!root.ssid.length || root.working)
			return;
		root.working = true;
		root.error = "";
		Network.connectToNetwork(root.ssid, root.password, root.bssid, result => {
			root.working = false;
			if (result && result.success) {
				root.close();
				return;
			}
			root.error = result && result.error ? result.error : "Unable to connect";
		});
	}

	Connections {
		target: Network
		function onConnectionFailed(ssid) {
			if (root.visible && root.ssid === ssid) {
				root.error = "Connection failed";
				root.working = false;
			}
		}
	}
}
