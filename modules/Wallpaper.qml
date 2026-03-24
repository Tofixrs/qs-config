import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.widgets
import qs.utils

PWindow {
	id: window
	name: "wallpaper"

	required property ShellScreen s
	screen: s

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Background

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
}
