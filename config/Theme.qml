pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../utils"

Singleton {
	id: root

	property var colors: ({})

	FileView {
		id: colorsFile
		path: `${Paths.strip(Paths.config)}/shell/colors.json`
		onLoaded: {
			try {
				root.colors = JSON.parse(text());
			} catch (e) {
				console.log("Error parsing colors.json:", e);
			}
		}
	}

	property string background: colors.background || "#1E1E2E"
	property string foreground: colors.foreground || "#181825"
	property string foreground2: colors.foreground2 || "#11111b"
	property string inactive: colors.inactive || "#585b70"
	property string accent: colors.accent || "#cba6f7"
	property string accept: colors.accept || "#a6e3a1"
	property string deny: colors.deny || "#f38ba8"
	property string active: colors.active || "#89b4fa"
	property string hover: colors.hover || "#313244"
	property string text: colors.text || "#cdd6f4"
	property real rounded: 10
	property string font: "JetBrainsMono Nerd Font"
	property int motionFast: 100
	property int motionBase: 150
	property real motionOvershoot: 1.03
}
