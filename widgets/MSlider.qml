import QtQuick.Controls
import QtQuick.Layouts
import QtQuick
import qs.services

Slider {
	id: slider
	Layout.fillWidth: true

	background: Rectangle {
		x: slider.leftPadding
		y: slider.topPadding + slider.availableHeight / 2 - height / 2
		implicitWidth: 200
		implicitHeight: 15
		width: slider.availableWidth
		height: implicitHeight
		radius: Theme.get().rounded
		color: Theme.get().inactive

		Rectangle {
			width: slider.visualPosition * parent.width
			height: parent.height
			color: Theme.getAccentColor()
			radius: Theme.get().rounded
		}
	}
	handle: Rectangle {
		x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
		y: slider.topPadding + slider.availableHeight / 2 - height / 2
		implicitWidth: 26
		implicitHeight: 26
		radius: 13
		color: slider.pressed ? Theme.getAccentColor() : Theme.get().inactive
		border.color: Theme.get().foreground
		border.width: 1
	}
}
