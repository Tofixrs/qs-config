import QtQuick.Layouts
import QtQuick.Controls
import QtQuick 2.15
import Quickshell
import Quickshell.Services.UPower
import qs.widgets

RowLayout {
	id: batteryDisplayRow
	spacing: 5

	property bool showBatteryText: false // Property to control visibility

	Image {
		id: batteryIcon
		source: {
			let displayDevice = UPower.displayDevice;

			if (displayDevice && displayDevice.percentage !== undefined) {
				let percentage = displayDevice.percentage * 100;
				let isCharging = displayDevice.state === UPowerDeviceState.Charging;

				let iconName = "battery-missing"; // Default fallback

				if (isCharging) {
					iconName = "battery-charging-symbolic";
				} else if (percentage >= 90) {
					iconName = "battery-full-charged-symbolic";
				} else if (percentage >= 75) {
					iconName = "battery-full-symbolic";
				} else if (percentage >= 50) {
					iconName = "battery-good-symbolic";
				} else if (percentage >= 25) {
					iconName = "battery-low-symbolic";
				} else if (percentage > 0) {
					iconName = "battery-empty-symbolic";
				} else {
					iconName = "battery-empty-symbolic";
				}
				return Quickshell.iconPath(iconName, "image-missing");
			}
			return ""; // No icon if no display device or percentage is undefined
		}
		Layout.preferredWidth: 16
		Layout.preferredHeight: 16
		fillMode: Image.PreserveAspectFit
	}

	MText {
		id: batteryText
		text: {
			let displayDevice = UPower.displayDevice;
			if (displayDevice && displayDevice.percentage !== undefined) {
				return `${displayDevice.percentage * 100}%`;
			} else {
				return "N/A"; // No battery percentage if no display device or percentage undefined
			}
		}
		verticalAlignment: Text.AlignVCenter
		opacity: showBatteryText ? 1 : 0
		Behavior on opacity {
			NumberAnimation {
				duration: 200
			}
		}
		Layout.preferredWidth: showBatteryText ? implicitWidth : 0
		Behavior on Layout.preferredWidth {
			NumberAnimation {
				duration: 200
			}
		}
	}
	HoverHandler {
		onHoveredChanged: showBatteryText = hovered
	}
}
