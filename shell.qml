//@ pragma UseQApplication
//@ pragma RespectSystemStyle
//@ pragma IconTheme Papirus-Dark

import Quickshell
import qs.modules.appLauncher
import qs.modules.bar
import qs.modules
import qs.services as Services

ShellRoot {
	readonly property bool _sessionLockLoaded: Services.SessionLock.locked

	Launcher {}
	Dashboard {}
	Calendar {}
	Notifications {}
	MonitorProfilesWindow {}
	Variants {
		model: Quickshell.screens

		Scope {
			id: s
			property ShellScreen modelData
			Wallpaper {
				s: s.modelData
			}
			DesktopOverlay {
				s: s.modelData
			}
			Bar {
				s: s.modelData
			}
			NotificationPopup {
				s: s.modelData
			}
			WifiAuthorizationWindow {
				s: s.modelData
			}
		}
	}
}
