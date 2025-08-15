import QtQuick
import qs.services

Rectangle {
	id: root
	property string text
	property alias font: text.font
	property string backgroundColor: Theme.get().foreground
	property string hoverColor: Theme.get().hover
	property string textColor: Theme.get().text
	property MouseArea mArea
	property var clickKey
	implicitWidth: text.width + 20
	implicitHeight: text.height + 10
	radius: Theme.get().rounded
	color: (activeFocus || mouseArea.containsMouse) ? root.hoverColor : root.backgroundColor
	Keys.onPressed: event => {
		if (!clickKey || event.key != clickKey)
			return;

		root.clicked();
	}

	signal clicked
	signal rightClicked

	MText {
		id: text
		text: root.text
		anchors.centerIn: parent
		color: root.textColor
	}

	MouseArea {
		id: mouseArea
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		hoverEnabled: true
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: mouse => {
			if (mouse.button == Qt.LeftButton || mouse.button == Qt.Key_Enter) {
				root.clicked();
			} else {
				root.rightClicked();
			}
		}
	}

	Component.onCompleted: {
		mArea = mouseArea;
	}
}
