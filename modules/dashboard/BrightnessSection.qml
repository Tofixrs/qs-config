import QtQuick
import QtQuick.Layouts
import qs.modules.dashboard
import qs.widgets
import qs.services
import qs.config

SectionCard {
	id: root

	readonly property int percent: Math.round(Brightness.brightness * 100)
	readonly property string iconName: {
		if (!Brightness.available || root.percent <= 0)
			return "brightness_low";
		if (root.percent < 40)
			return "brightness_medium";
		return "brightness_high";
	}

	headerItem: Component {
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 8

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				IconButton {
					icon: root.iconName
					iconPointSize: 18
					iconColor: Brightness.available ? Theme.active : Theme.inactive
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2

					MText {
						text: Brightness.available ? "Brightness" : "Brightness Unavailable"
						font.pointSize: 12
					}

					MText {
						text: Brightness.available ? `${root.percent}%` : "No backlight device"
						color: Theme.inactive
						font.pointSize: 10
					}
				}

				Item {
					Layout.fillWidth: true
				}
			}

			VolumeSlider {
				Layout.fillWidth: true
				from: 0
				to: 1
				stepSize: 0.01
				enabled: Brightness.available
				value: Brightness.brightness
				onValueChanged: {
					if (pressed)
						Brightness.setBrightness(value);
				}
			}

			Item {
				Layout.fillWidth: true
				implicitHeight: 4
			}
		}
	}
}
