pragma ComponentBehavior: Bound
import QtQuick
import qs.services
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import qs.widgets
import Quickshell.Services.Notifications

Item {
	id: root
	property real fontSize: 15
	required property Notif.Notif modelData
	readonly property bool hasAppIcon: modelData.appIcon.length > 0
	readonly property bool hasImage: modelData.image.length > 0
	property color color: Theme.get().background
	property color actionColor: Theme.get().foreground
	property bool shadow: true
	anchors.left: parent.left
	anchors.right: parent.right
	implicitHeight: inner.height
	function close() {
		root.modelData.popup = false;
	}

	Rectangle {
		id: inner
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		implicitHeight: content.height + 20
		radius: Theme.get().rounded

		color: root.color

		ColumnLayout {
			id: content
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.margins: 10
			RowLayout {
				Layout.alignment: Qt.AlignTop
				Layout.maximumHeight: 32
				Loader {
					asynchronous: true
					sourceComponent: IconImage {
						source: Quickshell.iconPath(root.modelData.appIcon, "image-missing")
						implicitSize: parent.height
					}
				}
				MText {
					wrapMode: Text.WrapAnywhere
					text: root.modelData.summary
					font.pointSize: root.fontSize * 4 / 3
					Layout.fillWidth: true
				}

				MButton {
					text: "close"
					font.family: "Material Symbols Rounded"
					font.pointSize: root.fontSize * 4 / 3
					radius: height
					onClicked: {
						root.close();
					}
				}
			}
			Image {
				id: img
				property string img: {
					if (!root.hasImage)
						return null;
					if (root.modelData.image.includes("/home/")) {
						return "file://" + root.modelData.image.substring(13, root.modelData.image.length);
					}
					return root.modelData.image;
				}
				Layout.fillWidth: true
				Layout.maximumHeight: 200
				source: this.img
				fillMode: Image.PreserveAspectFit
			}
			MText {
				wrapMode: Text.WrapAnywhere
				text: root.modelData.body
				font.pointSize: root.fontSize
				Layout.maximumWidth: parent.width
			}

			ColumnLayout {
				Repeater {
					model: root.modelData.actions
					MButton {
						Layout.fillWidth: true
						required property NotificationAction modelData
						font.pointSize: root.fontSize
						color: this.mArea.containsMouse ? Theme.get().hover : root.actionColor
						text: modelData.text
						onClicked: {
							modelData.invoke();
						}
					}
				}
			}
		}
	}

	RectangularShadow {
		visible: root.shadow
		anchors.fill: inner
		radius: inner.radius
		blur: 20
		z: -1
		spread: 1
		color: Qt.darker(inner.color, 1.6)
	}
}
