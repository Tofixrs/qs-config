import QtQuick.Layouts
import QtQuick
import Quickshell.Widgets
import qs.services
import qs.widgets
import qs.utils

Rectangle {
	Layout.fillWidth: true
	implicitHeight: 75
	color: Theme.get().foreground
	RowLayout {
		anchors.fill: parent
		anchors.margins: 5
		spacing: 20

		ClippingRectangle {
			implicitWidth: parent.height
			implicitHeight: parent.height
			radius: Theme.get().rounded
			IconImage {
				source: `${Paths.home}/.face`
				implicitSize: parent.height
			}
		}
		MText {
			text: `${Vars.userName}\n${Vars.osName}\n${Vars.uptime}`
		}
		Item {
			Layout.fillWidth: true
		}
		ColumnLayout {}
	}
}
