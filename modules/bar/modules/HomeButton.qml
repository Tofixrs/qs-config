import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.services

Module {
	button: true
	onClick: Visibilities.toggle("dashboard")

	RowLayout {
		spacing: 6

		MaterialIcon {
			text: "home"
			font.pointSize: 16
		}
	}
}
