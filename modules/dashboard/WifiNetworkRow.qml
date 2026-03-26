import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets
import qs.services

SurfaceCard {
	id: root

	required property var network
	readonly property bool hasNetwork: !!root.network

	readonly property bool active: root.hasNetwork && root.network.active
	readonly property bool saved: root.hasNetwork && Network.hasSavedProfile(root.network.ssid)
	readonly property bool connectable: root.hasNetwork && (!root.network.isSecure || root.saved)

	cardColor: Theme.foreground2
	padding: 8
	contentSpacing: 0
	clip: true
	implicitHeight: row.implicitHeight + 16

	function connectNetwork(): void {
		if (!root.network)
			return;
		Network.connectToNetworkWithPasswordCheck(root.network.ssid, root.network.isSecure, null, root.network.bssid);
	}

	RowLayout {
		id: row
		Layout.fillWidth: true
		spacing: 8

		MaterialIcon {
			text: root.hasNetwork && root.network.isSecure ? "wifi_lock" : "wifi"
			font.pointSize: 16
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 2

			MText {
				text: root.hasNetwork ? (root.network.ssid || "Hidden network") : ""
				font.pointSize: 11
			}

			MText {
				text: root.hasNetwork ? `${root.network.strength}% signal${root.saved ? " • saved" : ""}${root.active ? " • connected" : ""}` : ""
				color: Theme.inactive
				font.pointSize: 9
			}
		}

		Item {
			Layout.fillWidth: true
		}

		PillButton {
			visible: root.active
			text: "Disconnect"
			horizontalPadding: 12
			verticalPadding: 6
			onClick: Network.disconnectFromNetwork()
		}

		PillButton {
			visible: root.active
			text: "Forget"
			horizontalPadding: 12
			verticalPadding: 6
			disabled: !root.hasNetwork
			onClick: {
				if (root.hasNetwork)
					Network.forgetNetwork(root.network.ssid);
			}
		}

		PillButton {
			visible: !root.active
			text: "Connect"
			horizontalPadding: 12
			verticalPadding: 6
			onClick: {
				if (!root.connectable) {
					WifiAuthorization.open(root.network.ssid, root.network.bssid);
				} else if (root.hasNetwork) {
					root.connectNetwork();
				}
			}
		}
	}
}
