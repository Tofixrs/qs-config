import QtQuick
import QtQuick.Controls
import qs.config

TextField {
	id: root

	property int radius: Theme.rounded
	property color backgroundColor: Theme.foreground2
	property color borderColor: activeFocus ? Theme.active : Theme.hover
	property color textColor: Theme.text
	property color placeholderColor: Theme.inactive

	color: textColor
	font.family: Theme.font
	selectByMouse: true
	
	background: Rectangle {
		color: root.backgroundColor
		radius: root.radius
		border.color: root.borderColor
		border.width: 1

		Behavior on border.color {
			ColorAnimation { duration: Theme.motionFast }
		}
	}

	placeholderTextColor: placeholderColor
}
