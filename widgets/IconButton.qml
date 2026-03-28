import QtQuick
import qs.widgets
import qs.config

Rectangle {
	id: root

	property string icon: ""
	property color iconColor: Theme.text
	property int iconPointSize: 16
	property int diameter: 34
	property int acceptedButtons: Qt.LeftButton

	signal click(var event)

	implicitWidth: diameter
	implicitHeight: diameter
	radius: diameter / 2
	color: mouseArea.containsMouse ? Theme.hover : Theme.background
	scale: mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? Theme.motionOvershoot : 1)

	Behavior on color {
		ColorAnimation {
			duration: Theme.motionFast
		}
	}

	Behavior on scale {
		NumberAnimation {
			duration: Theme.motionFast
			easing.type: Easing.OutCubic
		}
	}

	MaterialIcon {
		anchors.centerIn: parent
		text: root.icon
		color: root.iconColor
		font.pointSize: root.iconPointSize
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		acceptedButtons: root.acceptedButtons
		hoverEnabled: true
		onClicked: event => root.click(event)
	}
}
