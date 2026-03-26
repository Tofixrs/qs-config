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
