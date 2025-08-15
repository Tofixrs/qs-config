import QtQuick.Layouts
import QtQuick
import qs.services
import qs.widgets
import Quickshell.Bluetooth

RowLayout {
	Layout.fillWidth: true
	GridLayout {
		columns: 2
		rows: 2
		uniformCellWidths: true
		uniformCellHeights: true
		Loader {
			asynchronous: true
			active: Bluetooth.defaultAdapter != null
			sourceComponent: SysToggle {
				active: Bluetooth.defaultAdapter.enabled
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
					case BluetoothAdapterState.Disabled:
						return "bluetooth_disabled";
					}
				}
				onClicked: {
					if (Bluetooth.defaultAdapter) {
						Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
					}
				}
			}
		}
		Loader {
			asynchronous: true
			active: Network.hasWifi
			sourceComponent: SysToggle {
				active: Network.wifiEnabled
				text: enabled ? "wifi" : "signal_wifi_off"
				onClicked: {
					Network.toggleWifi();
				}
			}
		}
		Rectangle {
			color: "transparent"
		}
		Rectangle {
			color: "transparent"
		}
	}

	component SysToggle: MButton {
		required property bool active
		font.family: "Material Symbols Rounded"
		font.pointSize: 20
		color: {
			if (active)
				return Theme.getAccentColor();
			return this.mArea.containsMouse ? Theme.get().hover : Theme.get().foreground;
		}
		textColor: active ? Theme.get().foreground : Theme.get().text
	}
	ColumnLayout {
		Loader {
			asynchronous: true
			active: Brightness.getSelectedInterface() != undefined
			visible: this.active
			sourceComponent: RowLayout {
				MButton {
					text: Icons.getBrightnessIcon(Brightness.getSelectedInterface()?.brightnessPercent)
					font.family: "Material Symbols Rounded"
					font.pointSize: 20
				}
				MSlider {
					Layout.fillWidth: true
					from: 0
					value: Brightness.getSelectedInterface()?.brightness
					to: Brightness.getSelectedInterface()?.maxBrightness

					onMoved: {
						Brightness.getSelectedInterface().setBrightness(this.value);
					}
				}
			}
		}
		Loader {
			asynchronous: true
			active: Audio.sink != null
			sourceComponent: RowLayout {
				MButton {
					onClicked: {
						Audio.sink.audio.muted = !Audio.muted;
					}
					text: Audio.sink.audio.muted ? "volume_off" : Icons.getVolumeIcon(Audio.sink.audio.volume * 100)
					font.family: "Material Symbols Rounded"
					font.pointSize: 20
				}
				MSlider {
					Layout.fillWidth: true
					from: 0
					value: Audio.volume
					to: 1
					onMoved: {
						Audio.setVolume(this.value);
					}
				}
			}
		}
	}
}
