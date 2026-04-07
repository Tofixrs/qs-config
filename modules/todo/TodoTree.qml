pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

ColumnLayout {
	id: root

	property var tasks: []
	property int depth: 0

	Layout.fillWidth: true
	spacing: 8

	Repeater {
		model: Array.isArray(root.tasks) ? root.tasks : []
		delegate: TodoRow {
			required property var modelData
			Layout.fillWidth: true
			taskData: modelData
			depth: root.depth
		}
	}
}
