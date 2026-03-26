pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property list<var> devices: []
	property string allOutput: ""
	property string pairedOutput: ""
	property string connectedOutput: ""

	function parseDevices(text: string): var {
		const lines = text.trim().split("\n");
		const out = [];

		for (const rawLine of lines) {
			const line = rawLine.trim();
			if (!line.startsWith("Device "))
				continue;

			const parts = line.split(" ");
			const address = parts[1] || "";
			const name = parts.slice(2).join(" ").trim();
			if (!address)
				continue;

			out.push({
				address: address,
				name: name
			});
		}

		return out;
	}

	function rebuildDevices(): void {
		const known = parseDevices(root.allOutput);
		const pairedSet = new Set(parseDevices(root.pairedOutput).map(device => device.address));
		const connectedSet = new Set(parseDevices(root.connectedOutput).map(device => device.address));
		const merged = known.map(device => ({
				address: device.address,
				name: device.name,
				paired: pairedSet.has(device.address),
				connected: connectedSet.has(device.address)
			}));

		merged.sort((a, b) => {
			if (a.connected !== b.connected)
				return a.connected ? -1 : 1;
			if (a.paired !== b.paired)
				return a.paired ? -1 : 1;
			return a.name.localeCompare(b.name);
		});

		root.devices = merged;
	}

	function refresh(): void {
		root.allOutput = "";
		root.pairedOutput = "";
		root.connectedOutput = "";
		root.devices = [];
		allProc.running = true;
		pairedProc.running = true;
		connectedProc.running = true;
	}

	function connectDevice(address: string): void {
		actionProc.command = ["bluetoothctl", "connect", address];
		actionProc.running = true;
	}

	function disconnectDevice(address: string): void {
		actionProc.command = ["bluetoothctl", "disconnect", address];
		actionProc.running = true;
	}

	function forgetDevice(address: string): void {
		actionProc.command = ["bluetoothctl", "remove", address];
		actionProc.running = true;
	}

	Component.onCompleted: refresh()

	Timer {
		interval: 8000
		running: true
		repeat: true
		onTriggered: root.refresh()
	}

	Process {
		id: allProc
		command: ["bluetoothctl", "devices"]
		stdout: StdioCollector {
			id: allDevices
			onStreamFinished: {
				root.allOutput = text;
				root.rebuildDevices();
			}
		}
		onExited: root.rebuildDevices() // qmllint disable signal-handler-parameters
	}

	Process {
		id: pairedProc
		command: ["bluetoothctl", "paired-devices"]
		stdout: StdioCollector {
			id: pairedDevices
			onStreamFinished: {
				root.pairedOutput = text;
				root.rebuildDevices();
			}
		}
		onExited: root.rebuildDevices() // qmllint disable signal-handler-parameters
	}

	Process {
		id: connectedProc
		command: ["bluetoothctl", "devices", "Connected"]
		stdout: StdioCollector {
			id: connectedDevices
			onStreamFinished: {
				root.connectedOutput = text;
				root.rebuildDevices();
			}
		}
		onExited: root.rebuildDevices() // qmllint disable signal-handler-parameters
	}

	Process {
		id: actionProc
		stdout: StdioCollector {}
		stderr: StdioCollector {}
		onExited: {
			root.refresh();
		}
	}
}
