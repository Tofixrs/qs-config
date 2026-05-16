pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
	id: root
	readonly property url home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
	readonly property url config: new URL(StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0].toString())
	readonly property url data: new URL(StandardPaths.standardLocations(StandardPaths.GenericDataLocation)[0].toString())

	function strip(path: url): string {
		return path.toString().replace("file://", "");
	}
}
