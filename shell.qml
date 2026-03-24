//@ pragma UseQApplication
//@ pragma RespectSystemStyle
//@ pragma IconTheme Papirus-Dark

import Quickshell
import qs.modules.appLauncher
import qs.modules.bar
import qs.modules

ShellRoot {
	Launcher {}
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
		}
	}
}
