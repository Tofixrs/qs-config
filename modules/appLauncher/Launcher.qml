pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
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
	name: LauncherService.panelName
	visible: Visibilities.is(root.name)
	readonly property int entryIconSize: 22

	Rectangle {
		id: launcherCard
		color: Theme.background
		anchors.fill: parent
		radius: Theme.rounded
		opacity: root.visible ? 1 : 0
		scale: root.visible ? 1 : 0.97

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.motionBase
				easing.type: Easing.OutCubic
			}
		}

		Behavior on scale {
			NumberAnimation {
				duration: Theme.motionBase
				easing.type: Easing.OutCubic
			}
		}
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

					Behavior on color {
						ColorAnimation {
							duration: Theme.motionFast
						}
					}

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
						text: LauncherService.query
						onTextEdited: LauncherService.query = text
						Keys.onPressed: event => {
							if (event.key == Qt.Key_Return) {
								LauncherService.activateFocused();
							}
							if (event.key == Qt.Key_Escape) {
								LauncherService.hide();
							}
							if (event.key == Qt.Key_Up) {
								LauncherService.moveFocus(-1);
							}
							if (event.key == Qt.Key_Down) {
								LauncherService.moveFocus(1);
							}
							if (event.key == Qt.Key_Tab) {
								LauncherService.moveFocus(1);
							}
						}
					}
				}
				Repeater {
					id: entries
					model: LauncherService.filteredEntries
					Rectangle {
						id: item
						anchors.left: content.left
						anchors.right: content.right
						implicitHeight: entryContent.implicitHeight + 16
						radius: Theme.rounded
						opacity: 0
						x: 10

						required property Entry modelData
						required property int index
						color: index == LauncherService.focusedEntry ? Theme.hover : Theme.foreground

						Behavior on color {
							ColorAnimation {
								duration: Theme.motionFast
							}
						}

						Component.onCompleted: entryEnter.restart()

						ParallelAnimation {
							id: entryEnter
							NumberAnimation {
								target: item
								property: "opacity"
								from: 0
								to: 1
								duration: Theme.motionBase + (index * 14)
								easing.type: Easing.OutCubic
							}
							NumberAnimation {
								target: item
								property: "x"
								from: 10
								to: 0
								duration: Theme.motionBase + (index * 14)
								easing.type: Easing.OutCubic
							}
						}

						RowLayout {
							id: entryContent
							anchors.top: parent.top
							anchors.bottom: parent.bottom
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.leftMargin: 10
							anchors.rightMargin: 10
							spacing: 5
							Image {
                                                            asynchronous: true
								visible: modelData.icon != "" && modelData.iconType == "system"
								source: Quickshell.iconPath(modelData.icon, "image-missing")
								Layout.preferredHeight: root.entryIconSize
								Layout.preferredWidth: root.entryIconSize

								fillMode: Image.PreserveAspectFit
							}
							MaterialIcon {
								visible: modelData.icon != "" && modelData.iconType == "material"
								font.pointSize: root.entryIconSize
								text: modelData.icon
							}
							Text {
								id: text
								text: modelData.name
								font.pointSize: 15
								color: Theme.text
								wrapMode: Text.Wrap
								clip: true
								Layout.fillWidth: true
							}
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		Visibilities.addPanel(root.name);
	}
}
