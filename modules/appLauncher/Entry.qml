import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../services"
import "../../widgets"

Rectangle {
	id: entry
	property string iconSource
	property string text
	property real iconWidth: -2137
	property real iconHeight: -2137
	function toggle() {
	}
	signal selected
	Layout.fillWidth: true
	Layout.fillHeight: true
	focusPolicy: Qt.StrongFocus
	focus: true
	color: activeFocus ? Theme.get().hover : Theme.get().foreground
	radius: Theme.get().rounded
	Keys.onPressed: event => {
		if (event.key != Qt.Key_Return)
			return;
		selected();
	}
	RowLayout {
		anchors.fill: parent
		anchors.margins: 5
		Image {
			source: entry.iconSource
			Layout.fillHeight: entry.iconHeight == -2137
			Layout.preferredWidth: entry.iconWidth == -2137 ? height : entry.iconWidth
			Layout.preferredHeight: entry.iconHeight == -2137 ? height : entry.iconHeight
			Layout.maximumHeight: 128
			Layout.maximumWidth: parent.width / 2

			fillMode: Image.PreserveAspectFit
		}
		MText {
			text: entry.text
			font.pointSize: 15
			Layout.fillWidth: true
			Layout.minimumWidth: parent.width / 2
			wrapMode: Text.WrapAnywhere
		}
	}
}
