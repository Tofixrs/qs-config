pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root
	property var panels: []
	function addPanel(name: string) {
		root.panels[name] = false;
	}
	function toggle(panel: string) {
		root.panels[panel] = !root.panels[panel];
		root.panelsChanged();
	}
	function set(panel: string, yes: bool) {
		root.panels[panel] = yes;
		root.panelsChanged();
	}

	function is(panel: string): bool {
		return root.panels[panel];
	}

	IpcHandler {
		target: "panels"
		function toggle(panel: string) {
			root.toggle(panel);
		}
		function set(panel: string, yes: bool) {
			root.set(panel, yes);
		}
		function is(panel: string): bool {
			return root.is(panel);
		}
	}
}
