pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../widgets"
import "../../services" as S
import "./modules"

Variants {
	id: root
	model: Quickshell.screens
	StyledWindow {
		id: win
		required property ShellScreen modelData
		screen: modelData
		name: "dashboard"
		anchors.bottom: true
		implicitWidth: child.width
		implicitHeight: child.height
		WlrLayershell.exclusionMode: ExclusionMode.Normal

		Rectangle {
			id: child
			width: 400
			height: 500
			color: S.Theme.get().background
			radius: S.Theme.get().rounded
			ColumnLayout {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: 20
				UserBar {}
				SysControls {}
				Weather {
					color: S.Theme.get().foreground
					implicitHeight: 100
					fontSize: 10
				}
			}
		}

		PropertyAnimation {
			id: anim
			target: child
			property: "y"
			duration: 100
			to: S.Visibilities.screens[win.modelData.name][win.name] ? 0 : child.height
			onRunningChanged: {
				if (this.running)
					return;
				const me = S.Visibilities.screens[win.modelData.name][win.name];
				if (me)
					return;
				if (!me)
					win.visible = false;
			}
		}
		Connections {
			target: S.Visibilities
			function onScreensChanged() {
				const me = S.Visibilities.screens[win.modelData.name][win.name];
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
			S.Visibilities.addPanel(win.name);
		}
	}
}
