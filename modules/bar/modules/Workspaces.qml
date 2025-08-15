pragma ComponentBehavior: Bound

import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell
import QtQuick
import "../../../services"
import "../../../widgets"

Module {
	id: root
	required property ShellScreen monitor
	property HyprlandMonitor hMonitor: Hyprland.monitorFor(root.monitor)
	RowLayout {
		Repeater {
			model: Hyprland.workspaces
			RowLayout {
				id: ws
				required property HyprlandWorkspace modelData
				function getState() {
					if (root.hMonitor.id == modelData.monitor.id && modelData.active)
						return "active";

					if (modelData.lastIpcObject.windows > 0)
						return "occupied";

					return "empty";
				}
				function getColor() {
					switch (getState()) {
					case "active":
						return Theme.getAccentColor();
					case "occupied":
						return Theme.get().active;
					default:
						return Theme.get().inactive;
					}
				}
				function getWidth() {
					switch (getState()) {
					case "active":
						return 10;
					case "occupied":
						return 7;
					default:
						return 5;
					}
				}
				MText {
					text: ws.modelData.name
				}
				Rectangle {
					id: wsIndicator
					color: ws.getColor()

					implicitWidth: 5
					implicitHeight: 5
					radius: 5

					PropertyAnimation {
						id: widthAnim
						target: wsIndicator
						property: "implicitWidth"
						to: ws.getWidth()
						running: true
						onRunningChanged: this.running = true
						duration: 50
					}
				}
			}
		}
	}
	Component.onCompleted: {
		HyprlandPlus.fakePropToImport = true;
	}
}
