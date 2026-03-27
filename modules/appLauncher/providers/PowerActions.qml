import Quickshell
import qs.modules.appLauncher

Variants {
	id: modeProvider
	enum Actions {
		Shutdown = 0,
		Sleep = 1,
		Reboot = 2,
		Logout = 3
	}
	model: [
		{
			action: PowerActions.Actions.Shutdown,
			name: "Shutdown",
			icon: "mode_off_on"
		},
		{
			action: PowerActions.Actions.Sleep,
			name: "Sleep",
			icon: "bedtime"
		},
		{
			action: PowerActions.Actions.Reboot,
			name: "Reboot",
			icon: "restart_alt"
		},
		{
			action: PowerActions.Actions.Logout,
			name: "Logout",
			icon: "logout"
		}
	]
	delegate: Entry {
		id: me
		iconType: "material"
		required property var modelData
		name: modelData.name
		mode: Mode.powerActions
		icon: modelData.icon
		selectionCallback: SelectionCallback {
			closeLauncher: true
			function callback() {
				switch (modelData.action) {
				case PowerActions.Actions.Shutdown:
					Quickshell.execDetached(["systemctl", "poweroff"]);
					break;
				case PowerActions.Actions.Sleep:
					Quickshell.execDetached(["systemctl", "suspend"]);
					break;
				case PowerActions.Actions.Reboot:
					Quickshell.execDetached(["systemctl", "reboot"]);
					break;
				case PowerActions.Actions.Logout:
					Quickshell.execDetached(["bash", "-c", `loginctl -- kill-session $(loginctl --json=short list-sessions | jq '.[] | select(.class == "user") | .session' -r)`]);
					break;
				}
			}
		}
	}
}
