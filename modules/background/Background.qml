import "../../widgets"
import "../../services" as Services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Variants {
	model: Quickshell.screens

	StyledWindow {
		id: win

		required property ShellScreen modelData

		screen: modelData
		name: "bg"
		WlrLayershell.layer: WlrLayer.Background
		WlrLayershell.exclusionMode: ExclusionMode.Ignore

		anchors.top: true
		anchors.bottom: true
		anchors.left: true
		anchors.right: true

		Wallpaper {}

		GridLayout {
			uniformCellWidths: true
			anchors.left: parent.left
			anchors.right: parent.right
			ColumnLayout {}
			ColumnLayout {
				id: column
				ColumnLayout {

					Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
					MText {
						Layout.alignment: Qt.AlignHCenter
						font.pointSize: 80
						text: timeClock.text
						color: "black"
						Clock {
							id: timeClock
							format: "hh:mm:ss"
							font.pointSize: parent.font.pointSize
							y: -5
							x: -5
						}
					}
					MText {
						Layout.alignment: Qt.AlignHCenter
						font.pointSize: 40
						text: dateClock.text
						color: "black"
						Clock {
							id: dateClock
							format: "dd MMM yyyy"
							font.pointSize: parent.font.pointSize
							y: -4
							x: -4
						}
					}
				}
				Weather {
					implicitHeight: 200
				}
			}
			ColumnLayout {}
		}
	}
}
