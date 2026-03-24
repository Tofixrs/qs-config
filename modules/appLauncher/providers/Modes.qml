import Quickshell
import qs.modules.appLauncher

Variants {
	id: modeProvider
	model: Object.keys(Mode).filter(v => typeof Mode[v] == "number")
	delegate: Entry {
		id: me
		required property string modelData
		name: {
			const n = modelData;
			return n[0].toUpperCase() + n.slice(1);
		}
		mode: Mode.modes
		icon: ""
		selectionCallback: SelectionCallback {
			closeLauncher: false
			swapToMode: Mode[me.modelData]
		}
	}
}
