pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Repeater {
    id: list
    function toggle() {
    }
    required property string mode
    required property string inputValue
    model: {
        if (mode != "app")
            return [];
        DesktopEntries.applications.values.filter(v => v.name.toLowerCase().includes(list.inputValue)).sort((a, b) => a.name.localeCompare(b.name)).slice(0, 5);
    }

    Entry {
        required property DesktopEntry modelData
        iconSource: Quickshell.iconPath(modelData.icon, "image-missing")

        text: modelData.name
        onSelected: {
            Quickshell.execDetached({
                command: [`${Quickshell.shellDir}/scripts/launchApp.sh`, modelData.runInTerminal ? modelData.command.join(" ") : `${modelData.id}.desktop`, modelData.runInTerminal],
                workingDirectory: modelData.workingDirectory
            });
            list.toggle();
        }
    }
}
