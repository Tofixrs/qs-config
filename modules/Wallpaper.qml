import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.utils
import qs.widgets

PWindow {
	id: window
	name: "wallpaper"

	required property ShellScreen s
	screen: s

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Background
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
	focusable: true

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}
	Image {
		id: image
		anchors.fill: parent
		source: Qt.resolvedUrl(Paths.home + "/wallpaper.png")
	}

	DesktopWidgets {}

	Timer {
		interval: 600000
		repeat: true
		running: true
		onTriggered: Weather.refreshCurrent()
	}

	Component.onCompleted: {
		Weather.refreshCurrent();
	}
}
