import qs.widgets
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.bar.modules

PWindow {
	id: win
	required property ShellScreen s
	screen: s
	name: "bar"

	anchors.bottom: true
	anchors.left: true
	anchors.right: true
	implicitHeight: 40
	WrapperItem {
		width: win.width - 10
		height: win.implicitHeight - 10
		anchors.centerIn: parent
		margin: 5

		GridLayout {
			columns: 3
			rows: 1
			anchors.fill: parent
			uniformCellWidths: true

			RowLayout {
				Clock {}
			}
			RowLayout {
				Layout.alignment: Qt.AlignCenter
				Workspaces {
					monitor: win.s
				}
			}
			RowLayout {
				Layout.alignment: Qt.AlignRight
				Status {}
				Tray {}
			}
		}
	}
}
