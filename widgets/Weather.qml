import QtQuick.Layouts
import QtQuick
import "../services"

Rectangle {
	id: root
	Layout.fillWidth: true
	radius: Theme.get().rounded
	color: Theme.get().background
	property real fontSize: 20
	RowLayout {
		anchors.fill: parent

		MaterialIcon {
			text: Weather.icon
			Layout.alignment: Qt.AlignHCenter
			font.pointSize: root.fontSize * 5
		}
		ColumnLayout {
			Layout.alignment: Qt.AlignHCenter
			Layout.fillHeight: true
			MText {
				font.pointSize: root.fontSize
				text: Weather.city
			}
			MText {
				font.pointSize: 20
				text: Weather.tempC
			}
			MText {
				font.pointSize: root.fontSize
				text: Weather.description
			}
		}
	}
}
