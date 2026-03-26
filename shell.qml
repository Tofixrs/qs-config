//@ pragma UseQApplication
//@ pragma RespectSystemStyle
//@ pragma IconTheme Papirus-Dark

import Quickshell
import qs.modules.appLauncher
import qs.modules.bar
import qs.modules

ShellRoot {
	Launcher {}
	Dashboard {}
	Calendar {}
	Notifications {}
	Variants {
		model: Quickshell.screens

			Scope {
				id: s
				property ShellScreen modelData
				Wallpaper {
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
