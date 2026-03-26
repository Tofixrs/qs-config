import QtQuick
import qs.widgets
import qs.config

Rectangle {
	id: root

	property string text: ""
	property bool active: false
	property bool disabled: false
	property color activeColor: Theme.active
	property color baseColor: Theme.background
	property color disabledColor: Theme.foreground
	property color textColor: disabled ? Theme.inactive : Theme.text
	property int horizontalPadding: 14
	property int verticalPadding: 8

	signal click

	implicitWidth: label.implicitWidth + (horizontalPadding * 2)
	implicitHeight: label.implicitHeight + (verticalPadding * 2)
	radius: implicitHeight / 2
	color: mouseArea.containsMouse ? Theme.hover : (disabled ? disabledColor : (active ? activeColor : baseColor))

	MText {
		id: label
		anchors.centerIn: parent
		text: root.text
		color: root.textColor
		font.pointSize: 10
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		hoverEnabled: true
		enabled: !root.disabled
		onClicked: root.click()
	}
}
