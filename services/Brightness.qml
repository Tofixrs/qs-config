pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property list<var> deviceNames

    Variants {
        id: devices
        model: root.deviceNames
        delegate: Device {
            id: device
            required property var modelData
            maxBrightness: modelData.maxBrightness
            brightness: modelData.brightness
            inter: modelData.inter

            FileView {
                path: `/sys/class/backlight/${device.inter}/brightness`
                watchChanges: true
                onTextChanged: {
                    device.brightness = Number(this.text());
                    device.brightnessChanged();
                }
                onFileChanged: this.reload()
            }
        }
    }
    Process {
        id: process
    }
    Process {
        id: getDevices
        running: true
        command: [`${Quickshell.shellDir}/scripts/getBacklightDevices.sh`]
        stdout: StdioCollector {
            onStreamFinished: {
                root.deviceNames = text.split("\n").slice(0, -1).map(v => {
                    const [inter, brightness, maxBrightness] = v.split(",");
                    if (Config.data.brightnessInterface == "")
                        Config.data.brightnessInterface = inter;

                    return {
                        brightness,
                        maxBrightness,
                        inter
                    };
                });
            }
        }
    }
    IpcHandler {
        target: "brightness"
        function getDevices(): string {
            return JSON.stringify(devices.instances);
        }
        function getSelectedInterface(): string {
            const inter = root.getSelectedInterface();
            return JSON.stringify({
                maxBrightness: inter.maxBrightness,
                interface: inter.inter,
                brightness: inter.brightness
            });
        }
        function setSelectedInterface(name: string) {
            root.setSelectedInterface(name);
        }
        function setBrightness(percent: real, direction: string): string {
            if (!["+", "-"].includes(direction))
                return "Invalid direction (+/-)";

            const inter = getSelectedInterface();
            let brightnessPercent = inter.brightnessPercent;
            brightnessPercent;
        }
    }
    function getSelectedInterface() {
        return devices.instances.find(v => v.inter == Config.data.brightnessInterface);
    }
    function setSelectedInterface(name: string) {
        Config.data.brightnessInterface = name;
    }

    Component.onCompleted: {}
    component Device: Item {
        required property real maxBrightness
        required property string inter
        property real brightness
        property real brightnessPercent: (brightness * 100) / maxBrightness

        function setBrightness(value: real) {
            process.command = ["dbus-send", "--system", "--print-reply", "--dest=org.freedesktop.login1", "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session.SetBrightness", "string:backlight", "string:amdgpu_bl1", `uint32:${value}`];
            process.running = true;
        }
        function setBrightnessPercent(value: real) {
            if (value > 1) {
                value = value / 100;
            }

            const v = maxBrightness * value;
            setBrightness(v);
        }
    }
}
