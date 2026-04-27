import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.config
import qs.widgets

RowLayout {
	id: root
	spacing: 8

	property bool showLabel: true
	property bool labelOnHover: false
	property color iconColor: charging ? Theme.accept : Theme.text
	property color textColor: Theme.text
	property int iconPointSize: 20
	property int textPointSize: 11
	readonly property var displayDevice: UPower.displayDevice
	readonly property bool available: displayDevice && displayDevice.percentage !== undefined
	readonly property int percentage: available ? Math.round(displayDevice.percentage * 100) : 0
	readonly property bool charging: available && displayDevice.state === UPowerDeviceState.Charging
	readonly property bool low: available && percentage <= 20 && !charging
	readonly property bool _showResolvedLabel: showLabel && (!labelOnHover || hover.hovered)
	readonly property string iconName: {
		if (!available)
			return "battery_alert";
		if (charging)
			return "battery_charging_full";
		if (percentage >= 95)
			return "battery_full";
		if (percentage >= 75)
			return "battery_6_bar";
		if (percentage >= 55)
			return "battery_5_bar";
		if (percentage >= 40)
			return "battery_4_bar";
		if (percentage >= 25)
			return "battery_3_bar";
		if (percentage >= 10)
			return "battery_2_bar";
		return "battery_1_bar";
	}
	readonly property string label: {
		if (!available)
			return "N/A";
		if (charging)
			return `${percentage}% charging`;
		return `${percentage}%`;
	}

	MaterialIcon {
		text: root.iconName
		font.pointSize: root.iconPointSize
		color: root.low ? Theme.deny : root.iconColor
	}

	MText {
		text: root.label
		font.pointSize: root.textPointSize
		color: root.low ? Theme.deny : root.textColor
		visible: root._showResolvedLabel
		opacity: visible ? 1 : 0
		Layout.preferredWidth: visible ? implicitWidth : 0

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.motionFast
			}
		}

		Behavior on Layout.preferredWidth {
			NumberAnimation {
				duration: Theme.motionFast
			}
		}
	}

	HoverHandler {
		id: hover
	}
}
