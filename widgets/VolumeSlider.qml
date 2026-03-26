import QtQuick
import QtQuick.Controls
import qs.config

Slider {
	id: root

	from: 0
	to: 1.5
	stepSize: 0.01
	live: true
	orientation: Qt.Horizontal
	implicitWidth: 220
	implicitHeight: 24
	leftPadding: 7
	rightPadding: 7

	background: Rectangle {
		x: root.leftPadding
		y: (root.height - height) / 2
		width: root.availableWidth
		height: 6
		radius: 3
		color: Theme.foreground

		Rectangle {
			width: root.visualPosition * parent.width
			height: parent.height
			radius: parent.radius
			color: Theme.active
		}
	}

	handle: Rectangle {
		x: root.leftPadding + (root.visualPosition * (root.availableWidth - width))
		y: (root.height - height) / 2
		width: 14
		height: 14
		radius: 7
		color: root.pressed ? Theme.text : Theme.hover
		border.width: 1
		border.color: Theme.background
	}
}
