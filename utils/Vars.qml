pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
	id: root
	property string uptime
	property string userName
	property string osName
	property string osPrettyName
	property string osId

	Process {
		id: userNameProc
		command: ["whoami"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {
				root.userName = text.replace("\n", "");
			}
		}
	}
	FileView {
		path: "/etc/os-release"
		onLoaded: {
			const lines = text().split("\n");
			root.osId = lines.find(l => l.startsWith("ID="))?.split("=")[1];
			const prettyNameValue = lines.find(l => l.startsWith("PRETTY_NAME="))?.split("=")[1];
			root.osPrettyName = prettyNameValue.substring(1, prettyNameValue.length - 1);
			root.osName = lines.find(l => l.startsWith("NAME="))?.split("=")[1];
		}
	}

	Timer {
		interval: 1000
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			fileUptime.reload();
		}
	}
	FileView {
		id: fileUptime

		path: "/proc/uptime"
		onLoaded: {
			const up = parseInt(text().split(" ")[0] ?? 0);

			const days = Math.floor(up / 86400);
			const hours = Math.floor((up % 86400) / 3600);
			const minutes = Math.floor((up % 3600) / 60);

			let str = "";
			if (days > 0)
				str += `${days}d`;
			if (hours > 0)
				str += `${str ? " " : ""}${hours}h`;
			if (minutes > 0 || !str)
				str += `${str ? " " : ""}${minutes}m`;
			root.uptime = str;
		}
	}
}
