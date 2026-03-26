pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.modules.appLauncher.providers
import Quickshell.Hyprland
import qs.services
import qs.widgets
import Quickshell.Widgets
import qs.config

PWindow {
	id: root
	anchors.top: true
	margins.top: 20
	exclusionMode: ExclusionMode.Ignore
	implicitWidth: 600
	implicitHeight: content.implicitHeight + wrap.margin * 2
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
	focusable: true
	name: "appLauncher"

	property int mode: Mode.all
	property int focusedEntry: 0
	property int shownEntries: 10
	visible: Visibilities.is(root.name)

	function hide() {
		focusedEntry = 0;
		input.text = "";
		mode = Mode.all;
		Visibilities.set(root.name, false);
	}
	Apps {
		id: appProvider
	}
	Modes {
		id: modeProvider
	}
	Calc {
		id: calcProvider
		input: input.text
	}
	PowerActions {
		id: powerActions
	}
	readonly property list<Entry> entries: [...appProvider.instances, ...modeProvider.instances, ...powerActions.instances, calcProvider].sort((a, b) => {
		if (a.mode != b.mode) {
			return a.mode - b.mode;
		}
		if (input.text != "" && a.name.toLowerCase().startsWith(input.text.toLowerCase()))
			return -1;
		if (input.text != "" && b.name.toLowerCase().startsWith(input.text.toLowerCase()))
			return 1;
		return a.name.localeCompare(b.name);
	})

	property list<Entry> filteredEntries: root.entries.filter(v => {
		if (v.mode == Mode.calc && root.mode == Mode.all)
			return true;
		const name = v.name.toLowerCase();
		const t = input.text.toLowerCase();
		if (t[0] == ">" && root.mode == Mode.all) {
			return v.mode == Mode.modes && name.includes(t.slice(1));
		}

		return (v.mode == root.mode || root.mode == Mode.all) && name.includes(t);
	}).slice(0, shownEntries)

	Rectangle {
		color: Theme.background
		anchors.fill: parent
		radius: Theme.rounded
		WrapperItem {
			id: wrap
			anchors.fill: parent
			margin: 10
			Column {
				id: content
				spacing: 5
				Rectangle {
					anchors.left: parent.left
					anchors.right: parent.right
					implicitHeight: input.implicitHeight + 20
					color: Theme.foreground2
					radius: Theme.rounded
					TextInput {
						id: input
						anchors.fill: parent
						anchors.topMargin: 10
						anchors.bottomMargin: 10
						anchors.leftMargin: 15
						anchors.rightMargin: 15
						font.pointSize: 15
						focus: true
						color: Theme.text
						Keys.onPressed: event => {
							if (event.key == Qt.Key_Return) {
								const selected = entries.itemAt(root.focusedEntry);
								const cb = selected.modelData.selectionCallback;

								if (cb.swapToMode != null) {
									root.mode = cb.swapToMode;
									input.text = "";
								}
								if (cb.callback != null) {
									cb.callback();
								}
								if (cb.closeLauncher) {
									root.hide();
								}
							}
							if (event.key == Qt.Key_Escape) {
								root.hide();
							}
							if (event.key == Qt.Key_Up) {
								root.focusedEntry--;
								if (root.focusedEntry < 0) {
									root.focusedEntry = 0;
								}
							}
							if (event.key == Qt.Key_Down) {
								root.focusedEntry++;
								if (root.focusedEntry >= filteredEntries.length) {
									root.focusedEntry = 0;
								}
							}
							if (event.key == Qt.Key_Tab) {
								root.focusedEntry++;
								if (root.focusedEntry >= filteredEntries.length) {
									root.focusedEntry = 0;
								}
							}
						}
					}
				}
				Repeater {
					id: entries
					model: filteredEntries
					Rectangle {
						id: item
						anchors.left: content.left
						anchors.right: content.right
						implicitHeight: entryContent.implicitHeight + 16
						radius: Theme.rounded

						required property Entry modelData
						required property int index
						color: index == root.focusedEntry ? Theme.hover : Theme.foreground

						RowLayout {
							id: entryContent
							anchors.top: parent.top
							anchors.bottom: parent.bottom
							anchors.left: parent.left
							anchors.leftMargin: 10
							spacing: 5
							Image {
								visible: modelData.icon != "" && modelData.iconType == "system"
								source: Quickshell.iconPath(modelData.icon, "image-missing")
								Layout.preferredHeight: text.implicitHeight
								Layout.preferredWidth: text.implicitHeight

								fillMode: Image.PreserveAspectFit
							}
							MaterialIcon {
								visible: modelData.icon != "" && modelData.iconType == "material"
								font.pointSize: Math.max(1, text.implicitHeight)
								text: modelData.icon
							}
							Text {
								id: text
								text: modelData.name
								font.pointSize: 15
								color: Theme.text
								Layout.maximumWidth: 10
							}
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		Visibilities.addPanel(root.name);
		LauncherService.register(root);
	}
}
