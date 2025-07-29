pragma Singleton
import "../utils"
import "../utils.js" as Utils

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    readonly property var defaults: {
        "theme": "fallback",
        "accent": "blue"
    }
    property var themes: {
        "fallback": {
            "background": "#1E1E2E",
            "foreground": "#181825",
            "foreground2": "#11111b",
            "inactive": "#585b70",
            "accent": {
                "red": "#f38ba8",
                "orange": "#fab387",
                "yellow": "#f9e2af",
                "green": "#a6e3a1",
                "blue": "#89b4fa",
                "purple": "#cba6f7"
            },
            "accept": "#a6e3a1",
            "deny": "#f38ba8",
            "active": "#89b4fa",
            "hover": "#313244",
            "text": "#cdd6f4",
            "rounded": 10,
            "font": "JetBrainsMono Nerd Font"
        }
    }

    IpcHandler {
        target: "theme"
        function get(): string {
            return Config.data.themeConfig.theme;
        }
        function set(name: string) {
            root.set(name);
        }
        function getAll(): string {
            return Object.keys(root.themes).join("\n");
        }
        function getColors(name: string): string {
            return JSON.stringify(root.themes[name]);
        }
        function getAccent(): string {
            return getAccent();
        }
        function getAccentColor(): string {
            return getAccentColor();
        }
        function setAccent(name: string) {
            root.setAccent(name);
        }
        function getFonts(): string {
            return Qt.fontFamilies().join("\n");
        }
    }

    function set(name: string) {
        Config.data.themeConfig.theme = name;
    }
    function setAccent(name: string) {
        Config.data.themeConfig.accent = name;
    }
    function get() {
        return themes[Config.data.themeConfig.theme];
    }
    function getAccent() {
        return Config.data.themeConfig.accent;
    }
    function getAccentColor() {
        return root.get().accent[getAccent()];
    }
    Process {
        id: themeWatcher
        command: [`${Quickshell.shellDir}/scripts/themeWatcher.sh`, Paths.strip(Paths.themes)]
        running: true
        stdout: SplitParser {
            onRead: text => {
                const [event, file, json] = text.split("|");
                const theme = file.split(".")[0];
                switch (event) {
                case "MODIFY":
                    root.themes[theme] = JSON.parse(json);
                    break;
                case "DELETE":
                    root.themes[theme] = undefined;
                    break;
                }
            }
        }
    }
}
