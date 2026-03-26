import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.modules.notifications
import qs.widgets
import qs.services

PWindow {
	id: root
	required property ShellScreen s
	screen: s
	name: "notificationPopup"

	anchors.top: true
	anchors.right: true
	margins.top: 16
	margins.right: 16
	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Top
	implicitWidth: 420
	implicitHeight: Math.min(500, viewport.contentHeight)
	visible: Notifications.popupNotifications.length > 0

	Flickable {
		id: viewport
		anchors.fill: parent
		contentWidth: width
		contentHeight: popupColumn.implicitHeight
		boundsBehavior: Flickable.StopAtBounds
		clip: true
		interactive: viewport.contentHeight > viewport.height

		ScrollBar.vertical: ScrollBar {
			active: viewport.interactive
			policy: viewport.contentHeight > viewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
		}

		Column {
			id: popupColumn
			width: viewport.width
			spacing: 8

			Repeater {
				model: Notifications.popupNotifications

				delegate: Item {
					id: popupItem
					required property var modelData
					width: popupColumn.width
					implicitHeight: toastCard.implicitHeight

					NotificationCard {
						id: toastCard
						width: popupItem.width
						notification: popupItem.modelData
						onDismissRequested: Notifications.hidePopup(popupItem.modelData)
					}

					Timer {
						interval: Notifications.popupDuration
						repeat: false
						running: true
						onTriggered: Notifications.hidePopup(popupItem.modelData)
					}
				}
			}
		}
	}
}
