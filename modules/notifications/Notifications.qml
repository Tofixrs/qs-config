pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import qs.widgets
import qs.services

Variants {
	model: Quickshell.screens

	StyledWindow {
		id: win
		required property ShellScreen modelData
		name: "notifs"
		screen: modelData
		anchors.right: true
		anchors.top: true
		implicitWidth: 500
		implicitHeight: Math.min(500, content.contentHeight)

		ScrollView {
			id: scrollView
			anchors.fill: parent
			contentHeight: content.contentHeight
			ListView {
				id: content
				property real contentHeight: {
					let sum = 0;
					for (let i = 0; i < this.count; i++) {
						sum += this.itemAtIndex(i).height + 20;
					}
					return sum;
				}
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: 10
				model: ScriptModel {
					values: [...Notif.popups].reverse()
				}
				reuseItems: true
				delegate: Item {
					id: item
					anchors.left: parent.left
					anchors.right: parent.right
					required property var modelData
					implicitHeight: notif.implicitHeight
					Notification {
						id: notif
						modelData: item.modelData
					}
				}
			}
		}
	}
}
