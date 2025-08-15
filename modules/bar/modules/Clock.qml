import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../../widgets"
import "../../../services"

Module {
	required property ShellScreen s
	button: true
	cursorShape: Qt.PointingHandCursor
	onClick: {
		Visibilities.toggle(s.name, "calendar");
	}
	Clock {
		color: Theme.get().text
		format: "hh:mm:ss"
		Layout.alignment: Qt.AlignVCenter
	}
}
