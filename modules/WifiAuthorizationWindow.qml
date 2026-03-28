import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.widgets
import qs.services
import qs.config
import Quickshell.Wayland

PWindow {
	id: root
	name: "wifiAuthorization"
	required property ShellScreen s
	screen: s

	property real contentHeight: contentLayout ? contentLayout.implicitHeight : 0
	property real contentWidth: contentLayout ? contentLayout.implicitWidth : 0
	implicitWidth: Math.max(360, contentWidth + 32)
	implicitHeight: Math.max(150, contentHeight + 32)
	visible: WifiAuthorization.visible
	focusable: true
	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Top

	property string titleText: WifiAuthorization.ssid ? `Authorize ${WifiAuthorization.ssid}` : "Authorize network"

	SurfaceCard {
		anchors.fill: parent
		width: Math.min(parent.width, Math.max(320, contentLayout ? contentLayout.implicitWidth + 32 : 360))
		cardColor: Theme.foreground
		cardBorderWidth: 1
		cardBorderColor: Theme.hover
		padding: 16
		contentSpacing: 12

		ColumnLayout {
			id: contentLayout
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: 10

			MText {
				text: titleText
				font.pointSize: 14
			}

			MText {
				text: "Enter the Wi-Fi password to authorize this network."
				color: Theme.inactive
				font.pointSize: 10
				wrapMode: Text.Wrap
			}

			TextField {
				id: passwordField
				placeholderText: "Password"
				echoMode: TextInput.Password
				text: WifiAuthorization.password
				onTextChanged: WifiAuthorization.password = text
				enabled: !WifiAuthorization.working
				Layout.fillWidth: true
				Keys.onReturnPressed: WifiAuthorization.submit()
			}

			MText {
				text: WifiAuthorization.error
				color: Theme.deny
				font.pointSize: 10
				visible: WifiAuthorization.error.length > 0
			}

			RowLayout {
				spacing: 10
				Layout.alignment: Qt.AlignRight

				PillButton {
					text: "Cancel"
					baseColor: Theme.foreground2
					onClick: WifiAuthorization.close()
					disabled: WifiAuthorization.working
				}

				PillButton {
					text: WifiAuthorization.working ? "Authorizing…" : "Authorize"
					disabled: WifiAuthorization.working || WifiAuthorization.password.length === 0
					onClick: WifiAuthorization.submit()
				}
			}
		}
	}
}
