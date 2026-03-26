pragma Singleton

import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.appLauncher

Singleton {
	id: root
	property string panelName: "appLauncher"
	property var launcherInstance

	function register(launcher) {
		root.launcherInstance = launcher;
	}

	function setMode(modeValue: int) {
		if (!root.launcherInstance)
			return;
		root.launcherInstance.mode = modeValue !== undefined && modeValue !== null ? modeValue : Mode.all;
	}

	function show(modeValue: int) {
		root.setMode(modeValue);
		Visibilities.set(root.panelName, true);
	}

	function hide() {
		Visibilities.set(root.panelName, false);
	}

	function toggle(modeValue: int) {
		if (Visibilities.is(root.panelName)) {
			root.hide();
			return;
		}
		root.show(modeValue);
	}

	IpcHandler {
		target: "launcher"
		function hide() {
			root.hide();
		}

		function toggle(modeValue: int) {
			root.toggle(modeValue);
		}

		function setMode(modeValue: int) {
			root.setMode(modeValue);
		}
	}
}
