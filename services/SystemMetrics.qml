pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
	id: root

	property real cpuUsage: 0
	property real memoryUsage: 0
	property real diskUsage: 0
	property string errorMessage: ""
	property real previousCpuTotal: 0
	property real previousCpuIdle: 0
	property bool cpuPrimed: false

	readonly property string cpuLabel: `${Math.round(root.cpuUsage * 100)}%`
	readonly property string memoryLabel: `${Math.round(root.memoryUsage * 100)}%`
	readonly property string diskLabel: `${Math.round(root.diskUsage * 100)}%`

	function clamp(value: real): real {
		return Math.max(0, Math.min(1, value));
	}

	function refresh(): void {
		cpuProc.running = true;
		memProc.running = true;
		diskProc.running = true;
	}

	function updateCpuFromStat(text: string): void {
		const fields = text.trim().split(/\s+/);
		if (fields.length < 5 || fields[0] !== "cpu")
			return;

		let total = 0;
		for (let i = 1; i < fields.length; i++) {
			const value = Number(fields[i]);
			if (!isNaN(value))
				total += value;
		}

		const idle = Number(fields[4]) + Number(fields[5] || 0);
		if (root.cpuPrimed) {
			const totalDiff = total - root.previousCpuTotal;
			const idleDiff = idle - root.previousCpuIdle;
			if (totalDiff > 0)
				root.cpuUsage = root.clamp((totalDiff - idleDiff) / totalDiff);
		}

		root.previousCpuTotal = total;
		root.previousCpuIdle = idle;
		root.cpuPrimed = true;
	}

	Component.onCompleted: refresh()

	Timer {
		interval: 10000
		running: true
		repeat: true
		onTriggered: root.refresh()
	}

	Process {
		id: cpuProc
		command: ["cat", "/proc/stat"]

		stdout: StdioCollector {
			onStreamFinished: {
				const firstLine = text.split("\n")[0] || "";
				root.updateCpuFromStat(firstLine);
			}
		}
	}

	Process {
		id: memProc
		command: ["cat", "/proc/meminfo"]

		stdout: StdioCollector {
			onStreamFinished: {
				const totalMatch = text.match(/^MemTotal:\s+(\d+)/m);
				const availableMatch = text.match(/^MemAvailable:\s+(\d+)/m);
				if (!totalMatch || !availableMatch)
					return;

				const total = Number(totalMatch[1]);
				const available = Number(availableMatch[1]);
				if (total > 0)
					root.memoryUsage = root.clamp((total - available) / total);
			}
		}
	}

	Process {
		id: diskProc
		command: ["sh", "-c", "df -P / | awk 'NR==2 {print $5}'"]

		stdout: StdioCollector {
			onStreamFinished: {
				const match = text.trim().match(/(\d+)%/);
				if (!match)
					return;

				root.diskUsage = root.clamp(Number(match[1]) / 100);
			}
		}
	}
}
