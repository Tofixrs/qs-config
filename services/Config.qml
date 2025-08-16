pragma Singleton

import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
	id: root
	property alias data: data

	FileView {
		id: fileView
		path: `${Paths.strip(Paths.config)}/config.json`
		watchChanges: true
		onFileChanged: reload()
		onAdapterUpdated: writeAdapter()
		onLoadFailed: {
			fileView.setText(JSON.stringify(data));
			fileView.reload();
		}
		JsonAdapter {
			id: data
			property string weatherLocation: ""
			property string currentWallpaper: "wallpaper.png"
			property string brightnessInterface: ""
			property JsonObject themeConfig: JsonObject {
				property string theme: "fallback"
				property string accent: "blue"
			}
		}
	}
}
