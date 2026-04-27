import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQuick
import qs.widgets
import qs.config

Module {
	id: root
	required property ShellScreen monitor
	property HyprlandMonitor hMonitor: Hyprland.monitorFor(root.monitor)
	property var workspaces: Hyprland.workspaces.values.filter(ws => ws.monitor?.id == hMonitor?.id)

	RowLayout {
		Repeater {
			model: root.workspaces
				RowLayout {
					id: ws
					required property HyprlandWorkspace modelData
					function toplevelCount() {
						return ws.modelData.toplevels?.values?.length || 0;
					}
					function getState() {
						if (root.hMonitor.id == modelData.monitor.id && modelData.active)
							return "active";

						if (toplevelCount() > 0)
							return "occupied";

						return "empty";
					}
				function getColor() {
					switch (getState()) {
					case "active":
						return Theme.accent;
					case "occupied":
						return Theme.active;
					default:
						return Theme.inactive;
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

					implicitWidth: ws.getWidth()
					implicitHeight: 5
					radius: 5

					Behavior on implicitWidth {
						NumberAnimation {
							duration: 50
						}
					}

					Behavior on color {
						ColorAnimation {
							duration: 50
						}
					}
				}
			}
		}
	}
}
