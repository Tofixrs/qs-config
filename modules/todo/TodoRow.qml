pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
	id: root

	property var taskData: ({
			id: -1,
			text: "",
			done: false,
			subtasks: []
		})
	property int depth: 0
	property bool expanded: true
	property bool addingSubtask: false
	property bool editing: false
	readonly property int taskId: Number(root.taskData && root.taskData.id)
	readonly property bool hasTaskId: root.taskId >= 0
	readonly property var currentTask: (root.hasTaskId ? TodoService.taskById(root.taskId) : null) || root.taskData || ({
			id: -1,
			text: "",
			done: false,
			subtasks: []
		})
	readonly property string taskText: root.currentTask.text ? `${root.currentTask.text}` : ""
	readonly property bool taskDone: root.currentTask.done === true
	readonly property var subtasks: Array.isArray(root.currentTask.subtasks) ? root.currentTask.subtasks : []

	Layout.fillWidth: true
	spacing: 8

	Rectangle {
		Layout.fillWidth: true
		radius: Theme.rounded
		color: Theme.foreground2
		border.width: 1
		border.color: Theme.hover
		implicitHeight: content.implicitHeight + 18

		Behavior on color {
			ColorAnimation {
				duration: Theme.motionFast
			}
		}

		ColumnLayout {
			id: content
			anchors.fill: parent
			anchors.margins: 9
			spacing: 8

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				IconButton {
					diameter: 28
					icon: root.taskDone ? "check_circle" : "radio_button_unchecked"
					iconPointSize: 18
					iconColor: root.taskDone ? Theme.accept : Theme.inactive
					onClick: {
						if (root.hasTaskId)
							TodoService.toggleTask(root.taskId);
					}
				}

				MTextField {
					id: editField
					Layout.fillWidth: true
					visible: root.editing
					text: root.taskText
					selectByMouse: true
					onAccepted: {
						if (root.hasTaskId)
							TodoService.updateTaskText(root.taskId, text);
						root.editing = false;
					}
				}

				MText {
					Layout.fillWidth: true
					visible: !root.editing
					text: root.taskText
					font.pointSize: 11
					wrapMode: Text.Wrap
					color: root.taskDone ? Theme.inactive : Theme.text
					font.strikeout: root.taskDone
				}

				IconButton {
					visible: root.subtasks.length > 0
					diameter: 28
					icon: root.expanded ? "expand_less" : "expand_more"
					iconPointSize: 18
					iconColor: Theme.inactive
					onClick: root.expanded = !root.expanded
				}

				IconButton {
					diameter: 28
					icon: root.editing ? "check" : "edit"
					iconPointSize: 16
					iconColor: Theme.text
					onClick: {
						if (root.editing) {
							if (root.hasTaskId)
								TodoService.updateTaskText(root.taskId, editField.text);
							root.editing = false;
							return;
						}

						root.editing = true;
						editField.forceActiveFocus();
						editField.selectAll();
					}
				}

				IconButton {
					diameter: 28
					icon: root.addingSubtask ? "remove" : "add"
					iconPointSize: 16
					iconColor: Theme.active
					onClick: {
						root.addingSubtask = !root.addingSubtask;
						if (!root.expanded)
							root.expanded = true;
					}
				}

				IconButton {
					diameter: 28
					icon: "delete"
					iconPointSize: 16
					iconColor: Theme.deny
					onClick: {
						if (root.hasTaskId)
							TodoService.removeTask(root.taskId);
					}
				}
			}

			RowLayout {
				visible: root.addingSubtask
				Layout.fillWidth: true
				spacing: 8

				Item {
					Layout.preferredWidth: 28
				}

				MTextField {
					id: subtaskField
					Layout.fillWidth: true
					placeholderText: "Add a subtask"
					selectByMouse: true
					onAccepted: {
						if (root.hasTaskId)
							TodoService.addSubtask(root.taskId, text);
						text = "";
						root.addingSubtask = false;
					}
				}

				PillButton {
					text: "Add"
					disabled: subtaskField.text.trim().length === 0
					onClick: {
						if (root.hasTaskId)
							TodoService.addSubtask(root.taskId, subtaskField.text);
						subtaskField.text = "";
						root.addingSubtask = false;
					}
				}
			}
		}
	}

	Loader {
		active: root.expanded && root.subtasks.length > 0
		Layout.fillWidth: true
		Layout.leftMargin: 22
		source: "TodoTree.qml"

		onLoaded: {
			item.tasks = Qt.binding(() => root.subtasks);
			item.depth = Qt.binding(() => root.depth + 1);
		}
	}
}
