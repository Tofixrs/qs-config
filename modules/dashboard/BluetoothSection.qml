import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Bluetooth
import qs.modules.dashboard
import qs.widgets
import qs.services
import qs.config

SectionCard {
	id: root

	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property real maxListHeight: 220
	readonly property var connectedDevice: BluetoothDevices.devices.find(device => device.connected)

	onExpandedChanged: {
		BluetoothDevices.refresh();
		if (root.adapter)
			root.adapter.discovering = root.expanded && root.adapter.enabled;
	}

	headerItem: Component {
		RowLayout {
			Layout.fillWidth: true
			spacing: 8

			IconButton {
				icon: root.adapter && root.adapter.enabled ? "bluetooth" : "bluetooth_disabled"
				iconPointSize: 18
				iconColor: root.adapter && root.adapter.enabled ? Theme.active : Theme.inactive
				acceptedButtons: Qt.RightButton
				onClick: event => {
					if (event.button === Qt.RightButton)
						root.expanded = !root.expanded;
				}
			}

			ColumnLayout {
				Layout.fillWidth: true
				spacing: 2

				MText {
					text: "Bluetooth"
					font.pointSize: 12
				}

				MText {
					text: {
						if (!root.adapter)
							return "No adapter";
						if (!root.adapter.enabled)
							return "Disabled";
						if (root.connectedDevice)
							return root.connectedDevice.name || root.connectedDevice.address;
						return "Enabled";
					}
					color: Theme.inactive
					font.pointSize: 10
				}
			}

			Item {
				Layout.fillWidth: true
			}

			PillButton {
				text: root.adapter && root.adapter.enabled ? "Turn Off" : "Turn On"
				active: root.adapter && root.adapter.enabled
				disabled: !root.adapter
				baseColor: Theme.foreground2
				onClick: {
					if (root.adapter)
						root.adapter.enabled = !root.adapter.enabled;
				}
			}

			IconButton {
				diameter: 28
				icon: root.expanded ? "expand_less" : "expand_more"
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				onClick: root.expanded = !root.expanded
			}
		}
	}

	ColumnLayout {
		Layout.fillWidth: true
		spacing: 6

		MText {
			text: {
				if (!root.adapter)
					return "Bluetooth adapter unavailable.";
				if (!root.adapter.enabled)
					return "Enable Bluetooth to manage devices.";
				return "Right click the Bluetooth icon to expand known devices.";
			}
			color: Theme.inactive
			font.pointSize: 10
		}

		Flickable {
			id: bluetoothViewport
			Layout.fillWidth: true
			Layout.preferredHeight: Math.min(bluetoothListContent.implicitHeight, root.maxListHeight)
			contentWidth: width
			contentHeight: bluetoothListContent.implicitHeight
			boundsBehavior: Flickable.StopAtBounds
			clip: true
			interactive: bluetoothViewport.contentHeight > bluetoothViewport.height

			ScrollBar.vertical: ScrollBar {
				active: bluetoothViewport.interactive
				policy: bluetoothViewport.contentHeight > bluetoothViewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
			}

			Column {
				id: bluetoothListContent
				width: bluetoothViewport.width
				spacing: 6

				Repeater {
					model: root.adapter && root.adapter.enabled ? BluetoothDevices.devices : []

					delegate: BluetoothDeviceRow {
						required property var modelData
						width: bluetoothViewport.width
						device: modelData
					}
				}
			}
		}
	}
}
