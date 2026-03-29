import Quickshell
import Quickshell.Io
import qs.modules.appLauncher
import QtQuick

Variants {
	id: clipboardProvider

	required property string input
	required property bool active
	property var clipboardEntries: []

	function shellQuote(value) {
		const source = value !== undefined && value !== null ? `${value}` : "";
		return `'${source.replace(/'/g, `'\"'\"'`)}'`;
	}

	function normalizePreview(value) {
		const source = value !== undefined && value !== null ? `${value}` : "";
		const compact = source.replace(/\s+/g, " ").trim();
		return compact.length > 0 ? compact : "(empty clipboard entry)";
	}

	function refresh() {
		if (!active) {
			clipboardEntries = [];
			return;
		}

		if (cliphist.running)
			return;

		cliphist.running = true;
	}

	model: clipboardEntries

	delegate: Entry {
		id: clipboardEntry
		required property var modelData
		name: modelData.preview
		icon: "content_paste"
		iconType: "material"
		mode: Mode.clipboard
		usageId: `clipboard:${modelData.id}`
		sortIndex: modelData.sortIndex
		payload: modelData.rawLine
		selectionCallback: SelectionCallback {
			closeLauncher: true
			callback: entrySnapshot => {
				const rawLine = entrySnapshot && entrySnapshot.payload ? `${entrySnapshot.payload}` : "";
				if (rawLine.length > 0) {
					Quickshell.execDetached(["bash", "-lc", `printf '%s\n' ${clipboardProvider.shellQuote(rawLine)} | cliphist decode | wl-copy`]);
				}
			}
		}
	}

	property var cliphist: Process {
		command: ["cliphist", "list"]
		stdout: StdioCollector {
			waitForEnd: true
		}
		stderr: StdioCollector {
			waitForEnd: true
		}
		onExited: exitCode => {
			if (exitCode !== 0) {
				clipboardProvider.clipboardEntries = [];
				return;
			}

			const lines = cliphist.stdout.text.split("\n").map(line => line.replace(/\s+$/, "")).filter(line => line.length > 0);
			clipboardProvider.clipboardEntries = lines.map((line, index) => {
				const separatorIndex = line.indexOf("\t");
				const id = separatorIndex >= 0 ? line.slice(0, separatorIndex) : line;
				const previewSource = separatorIndex >= 0 ? line.slice(separatorIndex + 1) : line;
				return {
					id: id,
					rawLine: line,
					preview: clipboardProvider.normalizePreview(previewSource),
					sortIndex: index
				};
			});
		}
	}

	onActiveChanged: refresh()
	Component.onCompleted: refresh()
}
