import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets
import qs.services

SurfaceCard {
	id: root

	required property var device
	readonly property bool hasDevice: !!root.device

	cardColor: Theme.foreground2
	padding: 8
	contentSpacing: 0
	clip: true
	implicitHeight: row.implicitHeight + 16

	RowLayout {
		id: row
		Layout.fillWidth: true
		spacing: 8

		MaterialIcon {
			text: "bluetooth"
			font.pointSize: 16
			color: root.hasDevice && root.device.connected ? Theme.active : Theme.inactive
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 2

			MText {
				text: root.hasDevice ? (root.device.name || root.device.address) : ""
				font.pointSize: 11
			}

			MText {
				text: root.hasDevice ? `${root.device.connected ? "connected" : "disconnected"}${root.device.paired ? " • paired" : ""}` : ""
				color: Theme.inactive
				font.pointSize: 9
			}
		}

		Item {
			Layout.fillWidth: true
		}

		PillButton {
			text: root.hasDevice && root.device.connected ? "Disconnect" : "Connect"
			horizontalPadding: 12
			verticalPadding: 6
			disabled: !root.hasDevice
			onClick: {
				if (!root.hasDevice)
					return;
				if (root.device.connected)
					BluetoothDevices.disconnectDevice(root.device.address);
				else
					BluetoothDevices.connectDevice(root.device.address);
			}
		}

		PillButton {
			visible: root.hasDevice && root.device.paired
			text: "Forget"
			horizontalPadding: 12
			verticalPadding: 6
			disabled: !root.hasDevice
			onClick: {
				if (root.hasDevice)
					BluetoothDevices.forgetDevice(root.device.address);
			}
		}
	}
}
