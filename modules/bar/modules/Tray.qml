pragma ComponentBehavior: Bound
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import QtQuick
import Quickshell.Widgets
import qs.widgets
import Quickshell

Module {
	id: root
	required property StyledWindow win
	RowLayout {
		Repeater {
			model: SystemTray.items

			Item {
				id: trayItem
				required property SystemTrayItem modelData
				implicitWidth: this.implicitHeight
				implicitHeight: 16

				IconImage {
					source: trayItem.modelData.icon
					implicitSize: 16
					anchors.centerIn: parent
				}
				MouseArea {
					id: mouseArea
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					property point mousePos: mouseArea.mapToGlobal(mouseArea.mouseX, mouseArea.mouseY)
					anchors.fill: parent
					onClicked: event => {
						switch (event.button) {
						case Qt.LeftButton:
							trayItem.modelData.activate();
							break;
						case Qt.RightButton:
							if (trayItem.modelData.hasMenu)
								menu.open();
							break;
						}
						event.accepted = true;
					}
				}

				QsMenuAnchor {
					id: menu

					menu: trayItem.modelData.menu
					anchor.item: trayItem
					anchor.rect.y: -root.height
					anchor.rect.height: trayItem.height
					anchor.rect.width: trayItem.width
					anchor.gravity: Edges.Bottom | Edges.Left
				}
			}
		}
	}
}
