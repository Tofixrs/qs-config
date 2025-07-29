pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    property bool fakePropToImport: false
    Connections {
        target: Hyprland
        function onRawEvent(ev: HyprlandEvent) {
            if (ev.name == "workspace")
                Hyprland.refreshWorkspaces();
        }
    }
}
