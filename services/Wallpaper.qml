pragma Singleton
import qs.utils

import Quickshell
import Quickshell.Io
import QtQuick
import qs.services

Singleton {
	id: root
	property list<string> wallpapers: []
	readonly property string currentWallpaper: Config.data.currentWallpaper
	readonly property list<string> extensions: ["jpg", "jpeg", "png", "tif", "tiff", "gif", "webp", "mp4", "webm"]

	IpcHandler {
		target: "wallpaper"
		function get(): string {
			return root.currentWallpaper;
		}
		function set(name: string) {
			root.setWallpaper(name ?? "");
		}
		function getAll(): string {
			return JSON.stringify(root.wallpapers);
		}
	}
	signal wallpaperChanged
	function setWallpaper(name: string) {
		if (!root.wallpapers.includes(name))
			return;
		Config.data.currentWallpaper = name;
		root.wallpaperChanged();
	}
	function isCurrentVid() {
		return root.currentWallpaper.endsWith(".mp4") || root.currentWallpaper.endsWith(".webm");
	}
	Process {
		id: wallpaperInit
		command: ["ls", "-1", Paths.strip(Paths.wallpaper)]
		running: true
		stdout: StdioCollector {
			onStreamFinished: () => {
				root.wallpapers = text.split("\n").filter(v => root.extensions.includes(v.slice(v.lastIndexOf(".") + 1))).sort();
				root.wallpaperChanged();
			}
		}
	}

	Process {
		id: wallpaperWatcher
		command: ["inotifywait", "-m", Paths.strip(Paths.wallpaper), "-e", "create", "-e", "move", "-e", "delete"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				const [event, filename] = data.split(" ").slice(1);
				if (!root.extensions.includes(filename.slice(filename.lastIndexOf(".") + 1))) {
					return;
				}
				switch (event) {
				case "MOVED_TO":
				case "CREATE":
					root.wallpapers.push(filename);
					break;
				case "MOVED_FROM":
				case "DELETE":
					root.wallpapers = root.wallpapers.filter(v => v != filename);
					if (root.currentWallpaper == filename) {
						root.setWallpaper(undefined);
					}
					break;
				}
			}
		}
	}
}
