import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.widgets

PWindow {
	id: root
	name: "desktopOverlay"

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
	focusable: true
	visible: Visibilities.is(root.name)

	Item {
		anchors.fill: parent
		focus: root.visible

		Keys.onEscapePressed: Visibilities.set(root.name, false)

		Rectangle {
			anchors.fill: parent
			color: "#66000000"
		}

		DesktopWidgets {
			anchors.fill: parent
			visible: root.visible
		}
	}

	Component.onCompleted: Visibilities.addPanel(root.name)
}
