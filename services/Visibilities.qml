pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var screens: Quickshell.screens.reduce((acc, v) => {
        acc[v.name] = {};
        panels.forEach(p => {
            acc[v.name][p] = false;
        });
        return acc;
    }, {})
    property list<string> panels: []
    function addPanel(name: string) {
        panels.push(name);
    }
    function toggle(screenNanme: string, panel: string) {
        root.screens[screenNanme][panel] = !root.screens[screenNanme][panel];
        root.screensChanged();
    }

    IpcHandler {
        target: "panels"
        function toggle(screenNanme: string, panel: string) {
            root.toggle(screenNanme, panel);
        }
    }
}
