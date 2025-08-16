import qs.widgets
import qs.services
import "./modules"
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

Variants {
	model: Quickshell.screens

	StyledWindow {
		id: win

		required property ShellScreen modelData
		screen: modelData
		name: "bar"

		anchors.bottom: true
		anchors.left: true
		anchors.right: true
		implicitHeight: 40
		WrapperItem {
			width: win.width
			height: win.implicitHeight - 10
			anchors.centerIn: parent
			margin: 5

			GridLayout {
				columns: 3
				rows: 1
				anchors.fill: parent
				uniformCellWidths: true
				RowLayout {
					Clock {
						s: win.modelData
					}
				}
				RowLayout {
					Layout.alignment: Qt.AlignHCenter
					Module {
						button: true
						onClick: Visibilities.toggle(win.modelData.name, "dashboard")
						MText {
							text: ""
						}
					}
					Workspaces {
						monitor: win.modelData
					}
					Module {
						button: true
						onClick: Visibilities.toggle(win.modelData.name, "notifBoard")
						MText {
							text: ""
						}
					}
				}
				RowLayout {
					Layout.alignment: Qt.AlignRight
				}
			}
		}
	}
}
