import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.services
import qs.widgets
import qs.config

SurfaceCard {
	id: root

	required property var notification
	property bool showDismiss: true
	signal dismissRequested
	readonly property bool hasNotificationImage: !!(root.notification.image && root.notification.image.length > 0)
	property string headerImageSource: root.notification.image || ""
	property int headerImageRetryCount: 0

	property string plainText: extractText(root.notification.body)
	property var imageSources: extractImageSources(root.notification.body)

	function extractText(html) {
		return html.replace(/<img[^>]+>/g, "").trim();
	}

	function extractImageSources(html) {
		var matches = [];
		var regex = /<img[^>]+src=['"]([^'"]+)['"][^>]*>/g;
		var match;
		while ((match = regex.exec(html)) !== null) {
			matches.push(match[1]);
		}
		return matches;
	}

	width: parent ? parent.width : implicitWidth
	cardColor: Theme.foreground
	cardBorderWidth: 1
	cardBorderColor: root.withAlpha(root.urgencyColor(), "#59")
	padding: 12
	contentSpacing: 10
	clip: true

	function urgencyColor(): color {
		if (!root.notification)
			return Theme.inactive;
		if (root.notification.urgency === NotificationUrgency.Critical)
			return Theme.deny;
		if (root.notification.urgency === NotificationUrgency.Low)
			return Theme.accept;
		return Theme.active;
	}

	function urgencyLabel(): string {
		if (!root.notification)
			return "Unknown";
		if (root.notification.urgency === NotificationUrgency.Critical)
			return "Critical";
		if (root.notification.urgency === NotificationUrgency.Low)
			return "Low";
		return "Normal";
	}

	function urgencyIcon(): string {
		if (!root.notification)
			return "notifications";
		if (root.notification.urgency === NotificationUrgency.Critical)
			return "release_alert";
		if (root.notification.urgency === NotificationUrgency.Low)
			return "notifications_paused";
		return "notifications";
	}

	function withAlpha(colorValue, alphaHex): color {
		const value = colorValue ? colorValue.toString() : Theme.inactive;
		if (value.startsWith("#") && value.length === 7)
			return `${alphaHex}${value.slice(1)}`;
		return value;
	}

	function reloadHeaderImage() {
		headerImageRetryCount = 0;
		headerImage.source = "";
		if (!headerImageSource)
			return;
		headerImageLoadTimer.restart();
	}

	onHeaderImageSourceChanged: reloadHeaderImage()

	Timer {
		id: headerImageLoadTimer
		interval: 50
		repeat: false
		onTriggered: headerImage.source = root.headerImageSource
	}

	Timer {
		id: headerImageRetryTimer
		interval: 125
		repeat: false
		onTriggered: {
			headerImage.source = "";
			headerImageLoadTimer.restart();
		}
	}

	Component.onCompleted: reloadHeaderImage()

	RowLayout {
		Layout.fillWidth: true
		spacing: 10

		Rectangle {
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: 4
			Layout.preferredHeight: 28
			radius: width / 2
			color: root.urgencyColor()
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 10

			RowLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignTop
				spacing: 8

				MaterialIcon {
					visible: !headerImage.visible && !appIconImage.visible
					Layout.alignment: Qt.AlignTop
					text: root.urgencyIcon()
					font.pointSize: 16
					color: root.urgencyColor()
				}

				Rectangle {
					visible: headerImage.status === Image.Ready
					Layout.alignment: Qt.AlignTop
					implicitWidth: 32
					implicitHeight: 32
					radius: 5
					color: Theme.foreground2
					clip: true

					Image {
						id: headerImage
						anchors.fill: parent
						visible: status === Image.Ready
						fillMode: Image.PreserveAspectCrop
						asynchronous: true
						cache: false
						smooth: true
						mipmap: true
						onStatusChanged: {
							if (status === Image.Error && root.headerImageSource && root.headerImageRetryCount < 3) {
								root.headerImageRetryCount += 1;
								headerImageRetryTimer.restart();
							}
						}
					}
				}

				Item {
					visible: !headerImage.visible && appIconImage.visible
					Layout.alignment: Qt.AlignTop
					implicitWidth: 32
					implicitHeight: 32

					IconImage {
						id: appIconImage
						anchors.centerIn: parent
						implicitSize: 32
						source: root.notification.appIcon ? Quickshell.iconPath(root.notification.appIcon, "") : ""
						visible: source.length > 0
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2

					MText {
						Layout.fillWidth: true
						text: root.notification.summary || root.notification.appName || "Notification"
						font.pointSize: 11
						wrapMode: Text.Wrap
						maximumLineCount: 1
						elide: Text.ElideRight
					}

					MText {
						Layout.fillWidth: true
						text: root.notification.appName || ""
						color: Theme.inactive
						font.pointSize: 9
						visible: text.length > 0
						wrapMode: Text.Wrap
						maximumLineCount: 1
						elide: Text.ElideRight
					}
				}

				Item {
					Layout.fillWidth: true
				}

				PillButton {
					Layout.alignment: Qt.AlignTop
					text: root.urgencyLabel()
					baseColor: root.withAlpha(root.urgencyColor(), "#29")
					textColor: root.urgencyColor()
					disabled: true
					horizontalPadding: 10
					verticalPadding: 6
				}

				PillButton {
					Layout.alignment: Qt.AlignTop
					visible: root.showDismiss
					text: "Dismiss"
					baseColor: Theme.background
					horizontalPadding: 12
					verticalPadding: 6
					onClick: {
						root.dismissRequested();
						Notifications.removeNotification(root.notification);
					}
				}
			}

			Text {
				Layout.fillWidth: true
				Layout.maximumWidth: parent.width
				text: root.plainText
				color: Theme.text
				font.family: Theme.font
				font.pointSize: 10
				visible: root.plainText.length > 0
				wrapMode: Text.Wrap
				textFormat: Text.RichText
				linkColor: root.urgencyColor()
				onLinkActivated: link => Qt.openUrlExternally(link)
			}
			Repeater {
				model: root.imageSources
				Item {
					required property string modelData
					implicitHeight: img.paintedHeight
					Layout.fillWidth: true
					Image {
						id: img
						anchors.left: parent.left
						anchors.right: parent.right
						fillMode: Image.PreserveAspectFit
						source: modelData
						asynchronous: true
						cache: false
						smooth: true
					}
				}
			}

			RowLayout {
				visible: root.notification.actions.length > 0
				Layout.fillWidth: true
				spacing: 6

				Repeater {
					model: root.notification.actions

					delegate: PillButton {
						required property var modelData
						text: modelData.text || "Action"
						baseColor: Theme.background
						horizontalPadding: 12
						verticalPadding: 6
						onClick: modelData.invoke()
					}
				}
			}
		}
	}
}
