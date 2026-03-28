pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Wayland
import qs.widgets
import qs.services
import qs.config

PWindow {
	id: root
	name: "calendar"

	anchors.bottom: true
	anchors.left: true
	WlrLayershell.layer: WlrLayer.Top
	exclusionMode: ExclusionMode.Normal
	implicitWidth: 360
	implicitHeight: Math.max(card.implicitHeight, 420)
	visible: Visibilities.is(root.name)

	property date date: new Date()

	SurfaceCard {
		id: card
		anchors.fill: parent
		cardColor: Theme.background
		cardBorderWidth: 1
		cardBorderColor: Theme.hover
		padding: 16
		contentSpacing: 12
		property real revealOffset: root.visible ? 0 : -root.implicitWidth
		opacity: root.visible ? 1 : 0
		scale: root.visible ? 1 : 0.97
		transform: Translate {
			x: card.revealOffset
		}

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

		Behavior on revealOffset {
			NumberAnimation {
				duration: Theme.motionBase
				easing.type: Easing.OutCubic
			}
		}

		ColumnLayout {
			spacing: 10

			RowLayout {
				Layout.fillWidth: true

				ColumnLayout {
					spacing: 2

					MText {
						text: "Calendar"
						font.pointSize: 14
					}

					MText {
						text: Qt.formatDate(root.date, "dddd, dd MMMM")
						color: Theme.inactive
						font.pointSize: 10
					}
				}

				Item {
					Layout.fillWidth: true
				}

				IconButton {
					diameter: 32
					icon: "close"
					iconPointSize: 14
					onClick: Visibilities.set(root.name, false)
				}
			}

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				PillButton {
					text: "<"
					baseColor: Theme.foreground2
					onClick: root.changeMonth(-1)
				}

				MText {
					id: monthLabel
					text: Qt.formatDate(root.date, "MMMM yyyy")
					font.pointSize: 12
					horizontalAlignment: Text.AlignHCenter
					Layout.fillWidth: true
					color: Theme.text
				}
				PillButton {
					text: ">"
					baseColor: Theme.foreground2
					onClick: root.changeMonth(1)
				}
			}
			Rectangle {
				Layout.fillWidth: true
				implicitHeight: dayOfWeek.height
				radius: Theme.rounded
				color: Theme.foreground

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
				Layout.fillWidth: true
				Layout.fillHeight: true
				month: root.date.getMonth()
				year: root.date.getFullYear()
				delegate: Rectangle {
					id: day
					required property var model
					implicitWidth: implicitHeight
					implicitHeight: text.implicitHeight + 10
					color: {
						if (model.date.getMonth() != root.date.getMonth())
							return Theme.inactive;
						if (model.date.getDay() == 0)
							return Theme.foreground2;

						return model.date.getDay() % 2 == 0 ? Theme.foreground : Theme.foreground2;
					}
					border.color: Theme.accent
					border.width: model.today ? 2 : 0
					radius: Theme.rounded

					Behavior on color {
						ColorAnimation {
							duration: Theme.motionFast
						}
					}

					Behavior on border.width {
						NumberAnimation {
							duration: Theme.motionFast
							easing.type: Easing.OutCubic
						}
					}
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

	function changeMonth(delta) {
		root.date.setMonth(root.date.getMonth() + delta);
	}

	Connections {
		target: Visibilities
		function onPanelsChanged() {
			if (Visibilities.is(root.name))
				return;
			root.date = new Date();
		}
	}

	Component.onCompleted: Visibilities.addPanel(root.name)
}
