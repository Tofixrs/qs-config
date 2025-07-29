import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    required property string name
    WlrLayershell.namespace: `quickshell-${name}`
    color: "transparent"
    function toggle() {
        Visibilities.toggle(screen.name, name);
    }
}
