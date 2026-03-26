import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.modules.notifications
import qs.widgets
import qs.services
import qs.config

PWindow {
	id: root
	name: "notifications"

	anchors.bottom: true
	WlrLayershell.layer: WlrLayer.Top
	exclusionMode: ExclusionMode.Normal
	implicitWidth: 520
	implicitHeight: Math.max(notificationCard.implicitHeight, 640)
	visible: Visibilities.is(root.name)

	SurfaceCard {
		id: notificationCard
		anchors.fill: parent
		cardColor: Theme.background
		cardBorderWidth: 1
		cardBorderColor: Theme.hover
		padding: 16
		contentSpacing: 14

		ColumnLayout {
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: 14

			RowLayout {
				Layout.fillWidth: true

				ColumnLayout {
					spacing: 2

					MText {
						text: "Notifications"
						font.pointSize: 14
					}

					MText {
						text: Notifications.count > 0 ? `${Notifications.count} tracked` : "No notifications"
						color: Theme.inactive
						font.pointSize: 10
					}
				}

				Item {
					Layout.fillWidth: true
				}

				PillButton {
					visible: Notifications.count > 0
					text: "Clear All"
					baseColor: Theme.foreground2
					onClick: Notifications.dismissAll()
				}

				IconButton {
					diameter: 30
					icon: "close"
					iconPointSize: 14
					onClick: Visibilities.set(root.name, false)
				}
			}

			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true

				Flickable {
					id: viewport
					anchors.fill: parent
					visible: Notifications.count > 0
					contentWidth: width
					contentHeight: notificationList.implicitHeight
					boundsBehavior: Flickable.StopAtBounds
					clip: true
					interactive: viewport.contentHeight > viewport.height

					ScrollBar.vertical: ScrollBar {
						active: viewport.interactive
						policy: viewport.contentHeight > viewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
					}

					ColumnLayout {
						id: notificationList
						width: viewport.width
						spacing: 8

						Repeater {
							id: notificationRepeater
							model: Notifications.notifications

							delegate: NotificationCard {
								required property var modelData
								width: viewport.width
								notification: modelData
							}
						}
					}
				}

				SurfaceCard {
					width: Math.min(parent.width, 320)
					cardColor: Theme.foreground
					padding: 20
					contentSpacing: 6
					visible: Notifications.count === 0
					anchors.left: parent.left
					anchors.right: parent.right

					ColumnLayout {
						spacing: 6
						Layout.alignment: Qt.AlignHCenter

						MaterialIcon {
							Layout.alignment: Qt.AlignHCenter
							text: "notifications_none"
							font.pointSize: 24
							color: Theme.inactive
						}

						MText {
							Layout.alignment: Qt.AlignHCenter
							text: "Nothing here"
							font.pointSize: 11
						}

						MText {
							Layout.alignment: Qt.AlignHCenter
							text: "Incoming notifications will stay here until dismissed."
							color: Theme.inactive
							font.pointSize: 9
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		Visibilities.addPanel(root.name);
	}
}
