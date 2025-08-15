pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../widgets"
import "../services"

Variants {
	id: root
	model: Quickshell.screens
	property date date: new Date()

	StyledWindow {
		id: win
		required property ShellScreen modelData
		screen: modelData
		name: "calendar"
		anchors.left: true
		anchors.bottom: true
		implicitWidth: child.width
		implicitHeight: child.height

		Rectangle {
			id: child
			width: 400
			height: 275
			color: Theme.get().background
			radius: Theme.get().rounded

			ColumnLayout {
				height: child.height - 20
				width: child.width - 50
				anchors.centerIn: parent
				RowLayout {
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignHCenter

					MButton {
						text: "-"
						onClicked: {
							root.date.setMonth(root.date.getMonth() - 1);
						}
					}
					MText {
						text: Qt.formatDateTime(root.date, "MMMM yyyy")
						horizontalAlignment: Text.AlignHCenter
					}
					MButton {
						text: "+"
						onClicked: {
							root.date.setMonth(root.date.getMonth() + 1);
						}
					}
				}
				Rectangle {
					Layout.fillWidth: true
					implicitHeight: dayOfWeek.height
					radius: Theme.get().rounded
					color: Theme.get().foreground

					DayOfWeekRow {
						id: dayOfWeek
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.margins: 10

						delegate: MText {
							required property var model
							horizontalAlignment: Text.AlignHCenter
							text: model.shortName
						}
					}
				}
				MonthGrid {
					id: monthGrid
					month: root.date.getMonth()
					year: root.date.getFullYear()
					Layout.fillWidth: true
					delegate: Rectangle {
						id: day
						required property var model
						implicitWidth: implicitHeight
						implicitHeight: text.implicitHeight + 10
						color: {
							if (model.date.getMonth() != root.date.getMonth())
								return Theme.get().inactive;
							if (model.date.getDay() == 0)
								return Theme.get().foreground2;

							return model.date.getDay() % 2 == 0 ? Theme.get().foreground : Theme.get().foreground2;
						}
						border.color: Theme.getAccentColor()
						border.width: model.today ? 2 : 0
						radius: Theme.get().rounded
						MText {
							id: text
							anchors.centerIn: parent
							horizontalAlignment: Text.AlignHCenter
							text: Qt.formatDate(day.model.date, "d")
						}
					}
				}
			}
		}
		PropertyAnimation {
			id: anim
			target: child
			property: "x"
			duration: 100
			to: Visibilities.screens[win.modelData.name][win.name] ? 0 : -child.width
			onRunningChanged: {
				if (this.running)
					return;
				const me = Visibilities.screens[win.modelData.name][win.name];
				if (me)
					return;
				if (!me)
					win.visible = false;
			}
		}
		Connections {
			target: Visibilities
			function onScreensChanged() {
				const me = Visibilities.screens[win.modelData.name][win.name];
				if (me == win.visible)
					return;
				if (win.visible) {
					anim.running = true;
				} else {
					win.visible = true;
					anim.running = true;
				}
			}
		}
		Component.onCompleted: {
			Visibilities.addPanel(win.name);
		}
	}
}
