import QtQuick
import QtQuick.Layouts
import qs.services

RowLayout {
	id: root
	default required property Item child
	property var cursorShape
	property bool button: false
	readonly property var cursor: {
		if (cursorShape)
			return cursorShape;
		return button ? Qt.PointingHandCursor : undefined;
	}
	signal click

	Rectangle {
		id: rect
		Layout.fillHeight: true
		implicitWidth: root.child.width + 20
		color: mouseArea.containsMouse && root.button ? Theme.get().hover : Theme.get().background
		radius: Theme.get().rounded

		MouseArea {
			id: mouseArea
			cursorShape: root.cursor
			anchors.fill: parent
			children: [root.child]
			hoverEnabled: true
			onClicked: {
				root.click();
			}
		}
		Component.onCompleted: {
			root.child.anchors.centerIn = mouseArea;
		}
	}
}
