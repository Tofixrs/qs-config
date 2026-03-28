import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.dashboard
import qs.widgets
import qs.services
import qs.config

PWindow {
	id: root
	name: "dashboard"

	anchors.bottom: true
	WlrLayershell.layer: WlrLayer.Top
	exclusionMode: ExclusionMode.Normal
	implicitWidth: 600
	implicitHeight: Math.max(dashboardCard.implicitHeight, 600)
	visible: Visibilities.is(root.name)

	SurfaceCard {
		id: dashboardCard
		anchors.fill: parent
		cardColor: Theme.background
		cardBorderWidth: 1
		cardBorderColor: Theme.hover
		padding: 16
		contentSpacing: 14
		property real revealOffset: root.visible ? 0 : root.implicitHeight
		opacity: root.visible ? 1 : 0
		scale: root.visible ? 1 : 0.97
		transform: Translate {
			y: dashboardCard.revealOffset
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
			id: content
			Layout.alignment: Qt.AlignTop
			Layout.fillWidth: true
			spacing: 14

			RowLayout {
				Layout.fillWidth: true

				ColumnLayout {
					spacing: 2

					MText {
						text: "Dashboard"
						font.pointSize: 14
					}

					MText {
						text: "Wireless controls"
						color: Theme.inactive
						font.pointSize: 10
					}
				}

				Item {
					Layout.fillWidth: true
				}

				PillButton {
					text: "Monitors"
					baseColor: Theme.foreground2
					onClick: Visibilities.set("monitorProfiles", true)
				}

				IconButton {
					diameter: 30
					icon: "close"
					iconPointSize: 14
					onClick: Visibilities.set(root.name, false)
				}
			}

			BrightnessSection {}
			VolumeSection {}
			WifiSection {}
			BluetoothSection {}
		}
	}

	Component.onCompleted: {
		Visibilities.addPanel(root.name);
	}
}
