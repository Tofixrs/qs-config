import qs.services
import qs.widgets

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import QtQuick.Effects

Variants {
	id: root
	model: Quickshell.screens

	StyledWindow {
		id: win
		required property ShellScreen modelData
		screen: modelData
		name: "powermenu"
		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		focusable: true
		visible: Visibilities.screens[win.modelData.name][win.name]
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

		Rectangle {
			id: content
			implicitWidth: 250
			implicitHeight: 250
			color: Theme.get().background
			radius: Theme.get().rounded
			Keys.onPressed: event => {
				if (event.key == Qt.Key_Escape) {
					win.toggle();
				}
			}

			anchors.centerIn: parent
			GridLayout {
				rows: 2
				columns: 2
				width: parent.implicitWidth - 30
				height: parent.implicitHeight - 30
				rowSpacing: 10
				columnSpacing: 10
				anchors.centerIn: parent
				uniformCellWidths: true
				uniformCellHeights: true

				PowerButton {
					text: "mode_off_on"
					onClicked: {
						Quickshell.execDetached(["systemctl", "poweroff"]);
					}
				}
				PowerButton {
					text: "bedtime"
					onClicked: {
						win.toggle();
						Quickshell.execDetached(["systemctl", "suspend"]);
					}
				}
				PowerButton {
					text: "restart_alt"
					onClicked: {
						Quickshell.execDetached(["systemctl", "reboot"]);
					}
				}
				PowerButton {
					text: "logout"
					onClicked: {
						Quickshell.execDetached(["bash", "-c", `loginctl -- kill-session $(loginctl --json=short list-sessions | jq '.[] | select(.class == "user") | .session' -r)`]);
					}
				}
			}
		}
		RectangularShadow {
			anchors.fill: content
			radius: content.radius
			blur: 20
			z: -1
			spread: 15
			color: Qt.darker(content.color, 1.6)
		}

		Component.onCompleted: {
			Visibilities.addPanel(win.name);
		}
	}

	component PowerButton: MButton {
		Layout.fillWidth: true
		Layout.fillHeight: true
		font.family: "Material Symbols Rounded"
		font.pointSize: 50
		focusPolicy: Qt.StrongFocus
		focus: true
		clickKey: Qt.Key_Return
	}
}
