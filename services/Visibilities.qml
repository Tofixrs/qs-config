pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root
	property var screens: Quickshell.screens.reduce((acc, v) => {
		acc[v.name] = {};
		panels.forEach(p => {
			acc[v.name][p] = false;
		});
		return acc;
	}, {})
	property list<string> panels: []
	function addPanel(name: string) {
		panels.push(name);
	}
	function toggle(screenName: string, panel: string) {
		root.screens[screenName][panel] = !root.screens[screenName][panel];
		root.screensChanged();
	}

	IpcHandler {
		target: "panels"
		function toggle(screenName: string, panel: string) {
			root.toggle(screenName, panel);
		}
	}
}
