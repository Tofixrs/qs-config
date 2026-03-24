import QtQuick

QtObject {
	id: entry

	required property string name
	required property string icon
	required property int mode
	required property SelectionCallback selectionCallback
}
