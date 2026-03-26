import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.services
import qs.config

Module {
	button: true

	Clock {
		color: Theme.text
		format: "hh:mm:ss | dd MMM ddd"
		Layout.alignment: Qt.AlignVCenter
	}

	onClick: {
		Visibilities.toggle("calendar");
	}
}
