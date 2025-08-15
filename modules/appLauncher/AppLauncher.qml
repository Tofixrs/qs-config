pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Io
import qs.widgets
import qs.services

Variants {
	id: root
	model: Quickshell.screens

	StyledWindow {
		id: win
		required property ShellScreen modelData
		screen: modelData
		anchors.top: true
		name: "appLauncher"
		margins.top: 20
		implicitWidth: 800
		implicitHeight: 500
		WlrLayershell.exclusionMode: ExclusionMode.Normal
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		focusable: true
		visible: Visibilities.screens[win.modelData.name][win.name]

		property string input: ""
		readonly property string inputValue: mode == "app" ? input : input.substring(2)
		readonly property string mode: {
			switch (win.input.substring(0, 2)) {
			case ">w":
				return "wallpaper";
			case ">+":
				return "calc";
			default:
				return "app";
			}
		}
		onInputValueChanged: {
			if (mode == "calc" && inputValue != "") {
				if (qalc.running) {
					qalc.signal(9);
				}
				const input = win.inputValue.replace(/\.$/, "").split(" ");
				qalc.command = ["qalc", "-m", "100", ...input];
				qalc.running = true;
			}
		}
		FocusScope {
			focus: true
			anchors.fill: parent

			Keys.onPressed: event => {
				const filter = [Qt.Key_Tab, Qt.Key_Delete, Qt.Key_Return, Qt.Key_Control, Qt.Key_Alt];
				if (event.key == Qt.Key_V && (event.modifiers & Qt.ControlModifier)) {
					win.input += Quickshell.clipboardText;
				} else if (event.key == Qt.Key_Escape) {
					win.toggle();
					win.input = "";
				} else if (event.key == Qt.Key_Backspace) {
					if (win.mode != "app" && inputValue == "") {
						win.input = "";
					} else {
						win.input = win.input.substring(0, win.input.length - 1);
					}
				} else {
					if (filter.includes(event.key))
						return;
					win.input += event.text;
				}
			}
			Rectangle {
				id: wrapper
				color: "transparent"
				anchors.fill: parent
				focus: true
				Rectangle {
					id: content
					anchors.fill: parent
					anchors.margins: 50
					color: Theme.get().background
					radius: Theme.get().rounded

					ColumnLayout {
						anchors.fill: parent
						anchors.margins: 20
						spacing: 5
						Rectangle {
							Layout.fillWidth: parent
							implicitHeight: 50
							color: Theme.get().foreground
							border.width: 3
							border.color: Theme.getAccentColor()
							radius: Theme.get().rounded
							Layout.alignment: Qt.AlignLeft | Qt.AlignTop

							MText {
								text: win.inputValue
								anchors.fill: parent
								anchors.leftMargin: 10
								font.pointSize: 20
								verticalAlignment: Qt.AlignVCenter
							}
						}

						Entry {
							id: calc
							visible: win.mode == "calc"
							Layout.fillHeight: true
							iconWidth: 0
							Process {
								id: qalc
								onRunningChanged: {}
								stdout: StdioCollector {
									onStreamFinished: {
										calc.text = text.trim();
									}
								}
							}
							onSelected: {
								Quickshell.execDetached(["sh", "-c", `qalc -t -m 100 '${win.inputValue}' | wl-copy`]);
								win.toggle();
								win.input = "";
							}
						}
						AppList {
							id: appList
							mode: win.mode
							inputValue: win.inputValue
							function toggle() {
								win.input = "";
								win.toggle();
							}
						}
						WallpaperList {
							id: wallList
							mode: win.mode
							inputValue: win.inputValue
							function toggle() {
								win.input = "";
								win.toggle();
							}
						}
					}
				}
				RectangularShadow {
					anchors.fill: content
					radius: content.radius
					blur: 20
					z: -1
					spread: 15
					color: Qt.darker(content.color, 1.6)
				}
			}
		}
		Component.onCompleted: {
			Visibilities.addPanel(win.name);
		}
	}
}
