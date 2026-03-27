pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property string deviceName: ""
	property int brightnessRaw: 0
	property int maxBrightnessRaw: 0
	property string lastError: ""
	readonly property bool available: root.deviceName.length > 0 && root.maxBrightnessRaw > 0
	readonly property real brightness: root.available ? Math.max(0, Math.min(1, root.brightnessRaw / root.maxBrightnessRaw)) : 0

	function refresh(): void {
		if (!root.deviceName) {
			detectDeviceProc.running = true;
			return;
		}

		readMaxProc.running = true;
		readBrightnessProc.running = true;
	}

	function setBrightness(value: real): void {
		if (!root.available)
			return;

		const clamped = Math.max(0, Math.min(1, value));
		const rawValue = Math.round(clamped * root.maxBrightnessRaw);
		root.lastError = "";

		setBrightnessProc.command = ["busctl", "--system", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", root.deviceName, `${rawValue}`];
		setBrightnessProc.running = true;
	}

	function changeBrightness(delta: real): void {
		root.setBrightness(root.brightness + delta);
	}

	Component.onCompleted: {
		refresh();
	}
	IpcHandler {
		target: "brightness"
		function change(delta: real) {
			root.changeBrightness(delta)
		}
		function set(value: real) {
			root.setBrightness(delta)
		}
	}

	Timer {
		interval: 2000
		running: true
		repeat: true
		onTriggered: root.refresh()
	}

	Process {
		id: detectDeviceProc
		command: ["bash", "-lc", "for d in /sys/class/backlight/*; do basename \"$d\"; break; done"]
		stdout: StdioCollector {
			onStreamFinished: {
				root.deviceName = text.trim();
				if (root.deviceName.length > 0)
					root.refresh();
			}
		}
	}

	Process {
		id: readBrightnessProc
		command: root.deviceName.length > 0 ? ["cat", `/sys/class/backlight/${root.deviceName}/brightness`] : ["true"]
		stdout: StdioCollector {
			onStreamFinished: {
				const parsed = parseInt(text.trim());
				if (!isNaN(parsed))
					root.brightnessRaw = parsed;
			}
		}
	}

	Process {
		id: readMaxProc
		command: root.deviceName.length > 0 ? ["cat", `/sys/class/backlight/${root.deviceName}/max_brightness`] : ["true"]
		stdout: StdioCollector {
			onStreamFinished: {
				const parsed = parseInt(text.trim());
				if (!isNaN(parsed))
					root.maxBrightnessRaw = parsed;
			}
		}
	}

	Process {
		id: setBrightnessProc
		stdout: StdioCollector {}
		stderr: StdioCollector {
			onStreamFinished: {
				const error = text.trim();
				if (error.length > 0)
					root.lastError = error;
			}
		}
		onExited: {
			root.refresh();
		}
	}
}
