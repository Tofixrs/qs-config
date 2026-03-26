import QtQuick.Layouts
import QtQuick.Controls
import QtQuick 2.15
import Quickshell
import Quickshell.Services.UPower
import qs.services
import qs.widgets

Module {
	RowLayout {
		VolumeStatus {}
		BatteryStatus {}
		NetworkStatus {}
		BluetoothStatus {}
	}
}
