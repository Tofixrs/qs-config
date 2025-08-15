import Quickshell
import qs.widgets
import qs.services
import QtQuick
import Quickshell.Wayland
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.notifications
import QtQuick.Controls

Variants {
	id: root
	model: Quickshell.screens
	StyledWindow {
	id: win
	required property ShellScreen modelData
	screen: modelData
	name: "notifBoard"
	anchors.bottom: true
	implicitWidth: child.width
	implicitHeight: child.height
	WlrLayershell.exclusionMode: ExclusionMode.Normal

	Rectangle {
		id: child
		width: 400
		height: 500
		color: Theme.get().background
		radius: Theme.get().rounded
		ColumnLayout {
		anchors.fill: parent
		anchors.margins: 20

		MText {
			text: "Notifications"
			font.pointSize: 12
		}
		ClippingRectangle {
			Layout.fillHeight: true
			Layout.fillWidth: true
			color: "transparent"
			ScrollView {
			anchors.fill: parent
			contentHeight: content.height
			ListView {
				id: content
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				spacing: 10
				model: ScriptModel {
				values: [...Notif.popups].reverse()
				}
				delegate: Notification {
				fontSize: 12
				shadow: false
				color: Theme.get().foreground
				actionColor: Theme.get().foreground2
				function close() {
					this.modelData.notification.dismiss();
				}
				}
			}
			}
		}
		}
	}

	PropertyAnimation {
		id: anim
		target: child
		property: "y"
		duration: 100
		to: Visibilities.screens[win.modelData.name][win.name] ? 0 : child.height
		onRunningChanged: {
		if (this.running)
			return;
		const me = Visibilities.screens[win.modelData.name][win.name];
		if (me)
			return;
		if (!me)
			win.visible = false;
		}
	}
	Connections {
		target: Visibilities
		function onScreensChanged() {
		const me = Visibilities.screens[win.modelData.name][win.name];
		if (me == win.visible)
			return;
		if (win.visible) {
			anim.running = true;
		} else {
			win.visible = true;
			anim.running = true;
		}
		}
	}
	Component.onCompleted: {
		Visibilities.addPanel(win.name);
	}
	}
}
