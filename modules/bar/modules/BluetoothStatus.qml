import QtQuick.Layouts
import QtQuick.Controls
import QtQuick 2.15
import Quickshell
import qs.widgets
import Quickshell.Bluetooth

RowLayout {
	id: bluetoothDisplayRow
	spacing: 5

	property bool showBluetoothText: false

	MaterialIcon {
		id: bluetoothIcon
		text: {
			if (Bluetooth.defaultAdapter == null)
				return "bluetooth_disabled";
			if (Bluetooth.devices.length > 0) {
				return "bluetooth_connected";
			}
			switch (Bluetooth.defaultAdapter.state) {
			case BluetoothAdapterState.Enabled:
				return "bluetooth";
			case BluetoothAdapterState.Enabling:
			case BluetoothAdapterState.Disabling:
				return "settings_bluetooth";
			case BluetoothAdapterState.Blocked:
			case BluetoothAdapterState.Disabled:
				return "bluetooth_disabled";
			}
		}
		font.pointSize: 16
	}

	MText {
		id: bluetoothText
		text: {
			let adapter = Bluetooth.defaultAdapter;
			if (!adapter) {
				return "N/A";
			}

			if (adapter.state === BluetoothAdapterState.Enabled) {
				if (adapter.devices.length > 0) {
					return adapter.connectedDevices[0].name; // Display name of first connected device
				}
				return "On";
			} else {
				return "Off";
			}
		}
		verticalAlignment: Text.AlignVCenter
		opacity: showBluetoothText ? 1 : 0
		Behavior on opacity {
			NumberAnimation {
				duration: 200
			}
		}
		Layout.preferredWidth: showBluetoothText ? implicitWidth : 0
		Behavior on Layout.preferredWidth {
			NumberAnimation {
				duration: 200
			}
		}
	}
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: showBluetoothText = true
		onExited: showBluetoothText = false
	}
}
