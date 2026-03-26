import QtQuick
import qs.widgets
import qs.services
import qs.config

Module {
	button: true
	onClick: Visibilities.toggle("notifications")

	Row {
		id: content
		spacing: 4

		MaterialIcon {
			id: icon
			text: Notifications.count > 0 ? "notifications_active" : "notifications"
			font.pointSize: 16
		}

		MText {
			id: countLabel
			visible: Notifications.count > 0
			text: `${Notifications.count}`
			color: Theme.active
			font.pointSize: 10
			anchors.verticalCenter: icon.verticalCenter
		}
	}
}
