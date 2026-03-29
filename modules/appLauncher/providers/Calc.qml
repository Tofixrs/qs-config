import Quickshell
import qs.modules.appLauncher
import Quickshell.Io

Entry {
	id: calcProvider

	required property bool active
	property string normalizedInput: ""
	property string pendingInput: ""
	property string query: ""
	property string result: ""
	property string runningQuery: ""
	function shellQuote(value) {
		const source = value !== undefined && value !== null ? `${value}` : "";
		return `'${source.replace(/'/g, `'\"'\"'`)}'`;
	}

	function copiedResult(value) {
		const source = value !== undefined && value !== null ? `${value}` : "";
		if (source.length === 0)
			return "";

		const lines = source.split("\n").map(line => line.trim()).filter(line => line.length > 0);
		if (lines.length === 0)
			return "";
		if (lines.length === 1) {
			const parts = lines[0].split(/\s=\s/);
			return parts.length > 1 ? parts[parts.length - 1].trim() : lines[0];
		}

		return lines[lines.length - 1];
	}

	function normalizeInput(value) {
		return value.trim().replace(/^=/, "").replace(/\.$/, "").trim();
	}

	function clearResult() {
		pendingInput = "";
		query = "";
		result = "";
	}

	function queueCalculation(nextInput) {
		if (!active || nextInput.length === 0 || nextInput.startsWith(">")) {
			clearResult();
			return;
		}

		pendingInput = nextInput;
		if (qalc.running)
			return;

		query = pendingInput;
		runningQuery = query;
		pendingInput = "";
		qalc.command = ["qalc", "-m", "100", query];
		qalc.running = true;
	}

	property var qalc: Process {
		stdout: StdioCollector {
			waitForEnd: true
		}
		stderr: StdioCollector {
			waitForEnd: true
		}
		onExited: exitCode => {
			const output = qalc.stdout.text.trim();
			if (calcProvider.normalizedInput === calcProvider.runningQuery)
				calcProvider.result = exitCode === 0 ? output : "";

			if (calcProvider.pendingInput.length > 0 && calcProvider.pendingInput !== calcProvider.query) {
				calcProvider.queueCalculation(calcProvider.pendingInput);
				return;
			}

			if (calcProvider.pendingInput === calcProvider.query)
				calcProvider.pendingInput = "";
		}
	}
	required property string input
	onInputChanged: {
		normalizedInput = normalizeInput(input);
		queueCalculation(normalizedInput);
	}
	onActiveChanged: {
		if (!active) {
			clearResult();
			return;
		}

		normalizedInput = normalizeInput(input);
		queueCalculation(normalizedInput);
	}
	name: result.length > 0 ? `${query} = ${result}` : ""
	icon: "calculate"
	iconType: "material"
	mode: Mode.calc
	selectionCallback: SelectionCallback {
		callback: entrySnapshot => {
			const source = entrySnapshot && entrySnapshot.result.length > 0 ? entrySnapshot.result : (entrySnapshot ? entrySnapshot.name : calcProvider.name);
			const copied = calcProvider.copiedResult(source);
			if (copied.length > 0) {
				Quickshell.execDetached(["bash", "-lc", `printf '%s' ${calcProvider.shellQuote(copied)} | wl-copy`]);
			}
		}
		closeLauncher: true
	}
}
