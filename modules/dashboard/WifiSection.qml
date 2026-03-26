import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.dashboard
import qs.widgets
import qs.services
import qs.config

SectionCard {
	id: root
	readonly property real maxListHeight: 220

	onExpandedChanged: {
		if (root.expanded && Network.wifiEnabled)
			Network.rescanWifi();
	}

	headerItem: Component {
		RowLayout {
			Layout.fillWidth: true
			spacing: 8

			IconButton {
				icon: Network.wifiEnabled ? "wifi" : "wifi_off"
				iconPointSize: 18
				iconColor: Network.wifiEnabled ? Theme.active : Theme.inactive
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
					text: Network.active ? Network.active.ssid : "Wi-Fi"
					font.pointSize: 12
				}

				MText {
					text: Network.wifiEnabled ? (Network.active ? `${Network.active.strength}% signal` : "Enabled") : "Disabled"
					color: Theme.inactive
					font.pointSize: 10
				}
			}

			Item {
				Layout.fillWidth: true
			}

			PillButton {
				text: Network.wifiEnabled ? "Turn Off" : "Turn On"
				active: Network.wifiEnabled
				baseColor: Theme.foreground2
				onClick: Network.enableWifi(!Network.wifiEnabled)
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

		Flickable {
			id: wifiViewport
			Layout.fillWidth: true
			Layout.preferredHeight: Math.min(wifiListContent.implicitHeight, root.maxListHeight)
			contentWidth: width
			contentHeight: wifiListContent.implicitHeight
			boundsBehavior: Flickable.StopAtBounds
			clip: true
			interactive: wifiViewport.contentHeight > wifiViewport.height

			ScrollBar.vertical: ScrollBar {
				active: wifiViewport.interactive
				policy: wifiViewport.contentHeight > wifiViewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
			}

			Column {
				id: wifiListContent
				width: wifiViewport.width
				spacing: 6

				Repeater {
					model: Network.wifiEnabled ? Network.networks : []

					delegate: WifiNetworkRow {
						required property var modelData
						width: wifiViewport.width
						network: modelData
					}
				}
			}
		}
	}
}
