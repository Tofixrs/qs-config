import QtQuick.Layouts
import QtQuick.Controls
import QtQuick 2.15
import Quickshell
import qs.services
import qs.widgets

RowLayout {
	id: networkDisplayRow
	spacing: 5

	property bool showNetworkText: false // Property to control visibility

	Image {
		id: networkIcon
		source: {
			if (Network.active) {
				let strength = Network.active.strength;
				if (strength >= 75)
					return Quickshell.iconPath("network-wireless-signal-excellent-symbolic", "image-missing");
				if (strength >= 50)
					return Quickshell.iconPath("network-wireless-signal-good-symbolic", "image-missing");
				if (strength >= 25)
					return Quickshell.iconPath("network-wireless-signal-ok-symbolic", "image-missing");
				return Quickshell.iconPath("network-wireless-signal-weak-symbolic", "image-missing");
			} else if (Network.activeEthernet) {
				return Quickshell.iconPath("network-wired-symbolic", "image-missing");
			}
			return Quickshell.iconPath("network-offline-symbolic", "image-missing");
		}
		Layout.preferredWidth: 16
		fillMode: Image.PreserveAspectFit
	}

	MText {
		id: networkText
		text: {
			if (Network.active) {
				return Network.active.ssid;
			} else if (Network.activeEthernet) {
				return "Ethernet";
			}
			return "No Network";
		}
		verticalAlignment: Text.AlignVCenter
		opacity: showNetworkText ? 1 : 0
		Behavior on opacity {
			NumberAnimation {
				duration: 200
			}
		}
		Layout.preferredWidth: showNetworkText ? implicitWidth : 0
		Behavior on Layout.preferredWidth {
			NumberAnimation {
				duration: 200
			}
		}
	}
	HoverHandler {
		onHoveredChanged: showNetworkText = hovered
	}
}
