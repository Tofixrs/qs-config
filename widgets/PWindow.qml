import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
	required property string name
	WlrLayershell.namespace: `quickshell-${name}`
	color: "transparent"
	function toggle() {
		Visibilities.toggle(screen.name, name);
	}
	function hide() {
		Visibilities.set(screen.name, name, false);
	}
	function show() {
		Visibilities.set(screen.name, name, true);
	}
}
