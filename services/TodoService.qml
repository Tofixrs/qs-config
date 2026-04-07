pragma Singleton

import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
	id: root

	readonly property string storagePath: `${Paths.strip(Paths.config)}/shell/todos.json`

	property var tasks: []
	property string errorMessage: ""
	property bool loaded: false
	property int nextId: 1

	readonly property int totalTasks: root.countTasks(root.tasks)
	readonly property int completedTasks: root.countCompletedTasks(root.tasks)

	function countTasks(list: var): int {
		let total = 0;
		const source = Array.isArray(list) ? list : [];
		for (let i = 0; i < source.length; i++)
			total += 1 + root.countTasks(source[i].subtasks || []);
		return total;
	}

	function countCompletedTasks(list: var): int {
		let total = 0;
		const source = Array.isArray(list) ? list : [];
		for (let i = 0; i < source.length; i++) {
			total += source[i].done === true ? 1 : 0;
			total += root.countCompletedTasks(source[i].subtasks || []);
		}
		return total;
	}

	function normalizeTask(task: var): var {
		const rawSubtasks = Array.isArray(task && task.subtasks) ? task.subtasks : [];
		const idValue = Number(task && task.id);
		return {
			id: Number.isFinite(idValue) && idValue > 0 ? Math.round(idValue) : root.generateId(),
			text: task && task.text ? `${task.text}` : "",
			done: task && task.done === true,
			subtasks: rawSubtasks.map(subtask => root.normalizeTask(subtask))
		};
	}

	function cloneTask(task: var): var {
		return {
			id: task.id,
			text: task.text,
			done: task.done === true,
			subtasks: (task.subtasks || []).map(subtask => root.cloneTask(subtask))
		};
	}

	function findTaskById(list: var, targetId: int): var {
		const source = Array.isArray(list) ? list : [];

		for (let i = 0; i < source.length; i++) {
			const item = source[i];
			if (item.id === targetId)
				return item;

			const nested = root.findTaskById(item.subtasks || [], targetId);
			if (nested !== null)
				return nested;
		}

		return null;
	}

	function taskById(targetId: int): var {
		return root.findTaskById(root.tasks, targetId);
	}

	function generateId(): int {
		const id = root.nextId;
		root.nextId += 1;
		return id;
	}

	function ensureNextId(): void {
		let maxId = 0;

		function scan(list) {
			const source = Array.isArray(list) ? list : [];
			for (let i = 0; i < source.length; i++) {
				const currentId = Number(source[i].id);
				if (Number.isFinite(currentId) && currentId > maxId)
					maxId = currentId;
				scan(source[i].subtasks || []);
			}
		}

		scan(root.tasks);
		root.nextId = maxId + 1;
	}

	function persist(): void {
		storageFile.setText(JSON.stringify({
			tasks: root.tasks
		}, null, 2));
	}

	function setTasks(nextTasks: var): void {
		root.tasks = Array.isArray(nextTasks) ? nextTasks : [];
		root.ensureNextId();
		root.persist();
	}

	function addTask(text: string): void {
		const trimmed = text.trim();
		if (trimmed.length === 0)
			return;

		const nextTasks = root.tasks.slice();
		nextTasks.unshift({
			id: root.generateId(),
			text: trimmed,
			done: false,
			subtasks: []
		});
		root.setTasks(nextTasks);
	}

	function replaceTask(list: var, targetId: int, updater: var): var {
		const next = [];
		const source = Array.isArray(list) ? list : [];

		for (let i = 0; i < source.length; i++) {
			const item = root.cloneTask(source[i]);
			if (item.id === targetId) {
				next.push(updater(item));
				continue;
			}

			item.subtasks = root.replaceTask(item.subtasks, targetId, updater);
			next.push(item);
		}

		return next;
	}

	function removeTaskFrom(list: var, targetId: int): var {
		const next = [];
		const source = Array.isArray(list) ? list : [];

		for (let i = 0; i < source.length; i++) {
			const item = root.cloneTask(source[i]);
			if (item.id === targetId)
				continue;
			item.subtasks = root.removeTaskFrom(item.subtasks, targetId);
			next.push(item);
		}

		return next;
	}

	function updateTaskText(taskId: int, text: string): void {
		const trimmed = text.trim();
		if (trimmed.length === 0)
			return;

		root.setTasks(root.replaceTask(root.tasks, taskId, task => {
			task.text = trimmed;
			return task;
		}));
	}

	function toggleTask(taskId: int): void {
		root.setTasks(root.replaceTask(root.tasks, taskId, task => {
			task.done = !task.done;
			return task;
		}));
	}

	function addSubtask(parentId: int, text: string): void {
		const trimmed = text.trim();
		if (trimmed.length === 0)
			return;

		root.setTasks(root.replaceTask(root.tasks, parentId, task => {
			const nextSubtasks = task.subtasks.slice();
			nextSubtasks.push({
				id: root.generateId(),
				text: trimmed,
				done: false,
				subtasks: []
			});
			task.subtasks = nextSubtasks;
			return task;
		}));
	}

	function removeTask(taskId: int): void {
		root.setTasks(root.removeTaskFrom(root.tasks, taskId));
	}

	FileView {
		id: storageFile
		path: root.storagePath
		printErrors: false

		onLoaded: {
			try {
				const parsed = JSON.parse(storageFile.text());
				const rawTasks = Array.isArray(parsed) ? parsed : (Array.isArray(parsed.tasks) ? parsed.tasks : []);
				root.tasks = rawTasks.map(task => root.normalizeTask(task));
				root.ensureNextId();
				root.errorMessage = "";
			} catch (error) {
				root.tasks = [];
				root.nextId = 1;
				root.errorMessage = `Unable to parse todo storage: ${error}`;
			}

			root.loaded = true;
		}

		onLoadFailed: error => {
			root.tasks = [];
			root.nextId = 1;
			root.loaded = true;
			root.errorMessage = "";
		}

		onSaved: {
			root.errorMessage = "";
		}

		onSaveFailed: error => {
			root.errorMessage = `Unable to save todos: ${error}`;
		}
	}
}
