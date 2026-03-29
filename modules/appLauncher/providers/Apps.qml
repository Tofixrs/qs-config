import Quickshell
import qs.modules.appLauncher

Variants {
	id: appProvider
	model: DesktopEntries.applications.values
	delegate: Entry {
		id: ea
		required property DesktopEntry modelData
		name: modelData.name
		icon: modelData.icon
		mode: Mode.apps
		usageId: `app:${modelData.id}`
		selectionCallback: SelectionCallback {
			closeLauncher: true
			callback: () => {
				if (ea.modelData.runInTerminal) {
					Quickshell.execDetached({
						command: ["bash", "-c", `'uwsm app -- $TERMINAL -e ${ea.modelData.command.join(" ")}'`],
						workingDirectory: ea.modelData.workingDirectory
					});
				} else {
					Quickshell.execDetached({
						command: ["uwsm", "app", `${ea.modelData.id}.desktop`],
						workingDirectory: ea.modelData.workingDirectory
					});
				}
			}
		}
	}
}
