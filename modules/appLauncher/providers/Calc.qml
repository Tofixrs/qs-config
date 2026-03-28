import Quickshell
import qs.modules.appLauncher
import Quickshell.Io

Entry {
	id: calcProvider

	property string normalizedInput: ""
	property string pendingInput: ""
	property string query: ""
	property string result: ""
	property string runningQuery: ""

	function normalizeInput(value) {
		return value.trim().replace(/^=/, "").replace(/\.$/, "").trim();
	}

	function clearResult() {
		pendingInput = "";
		query = "";
		result = "";
	}

	function queueCalculation(nextInput) {
		if (nextInput.length === 0 || nextInput.startsWith(">")) {
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

			if (calcProvider.pendingInput.length > 0
					&& calcProvider.pendingInput !== calcProvider.query) {
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
	name: result.length > 0 ? `${query} = ${result}` : ""
	icon: "calculate"
	iconType: "material"
	mode: Mode.calc
	selectionCallback: SelectionCallback {
		callback: () => {
			if (calcProvider.result.length > 0)
				Quickshell.execDetached(["wl-copy", "--", calcProvider.result]);
		}
		closeLauncher: true
	}
}
