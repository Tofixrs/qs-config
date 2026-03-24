import Quickshell
import qs.modules.appLauncher
import Quickshell.Io

Entry {
	id: calcProvider
	property var qalc: Process {
		onRunningChanged: {}
		stdout: StdioCollector {
			waitForEnd: true
		}
	}
	required property string input
	onInputChanged: {
		if (input == "")
			return;
		const i = input.replace(/\.$/, "").split(" ");
		qalc.command = ["qalc", "-m", "100", ...i];
		qalc.running = true;
	}
	name: qalc.stdout.text.trim()
	icon: ""
	mode: Mode.calc
	selectionCallback: SelectionCallback {
		callback: () => {
			Quickshell.execDetached(["bash", "-c", `'qalc -t -m 100 "${calcProvider.input}" | wl-copy'`]);
		}
		closeLauncher: true
	}
}
