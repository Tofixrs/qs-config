import QtQuick

QtObject {
	id: entry

	required property string name
	required property string icon
	required property int mode
	required property SelectionCallback selectionCallback
	property string iconType: "system"
	property string usageId: ""
	property int sortIndex: -1
	property var payload: null
}
