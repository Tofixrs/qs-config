import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
	id: root

	default property alias content: contentLayout.data
	property color cardColor: Theme.foreground
	property color cardBorderColor: "transparent"
	property int cardBorderWidth: 0
	property real padding: 10
	property real contentSpacing: 8

	Layout.fillWidth: true
	color: cardColor
	radius: Theme.rounded
	border.color: cardBorderColor
	border.width: cardBorderWidth
	implicitHeight: contentLayout.implicitHeight + (padding * 2)

	Behavior on color {
		ColorAnimation {
			duration: Theme.motionBase
		}
	}

	Behavior on border.color {
		ColorAnimation {
			duration: Theme.motionBase
		}
	}

	Behavior on border.width {
		NumberAnimation {
			duration: Theme.motionFast
			easing.type: Easing.OutCubic
		}
	}

	Behavior on implicitHeight {
		NumberAnimation {
			duration: Theme.motionBase
			easing.type: Easing.OutCubic
		}
	}

	ColumnLayout {
		id: contentLayout
		anchors.fill: parent
		anchors.margins: root.padding
		spacing: root.contentSpacing
	}
}
