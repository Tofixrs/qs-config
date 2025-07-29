pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property bool wifiEnabled: false
    Process {
        id: radioWatchProcess
        command: ["nmcli", "r", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() == "enabled";
            }
        }
    }
    Process {
        id: proc
    }
    function toggleWifi() {
        proc.command = ["nmcli", "r", "wifi", !root.wifiEnabled ? "on" : "off"];
        proc.running = true;
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            radioWatchProcess.running = true;
        }
    }
}
