import Quickshell
import qs.modules.appLauncher
import qs.services

Variants {
	id: emojiProvider

	required property string input
	required property int launcherMode
	property int shownEntries: 25

	model: EmojiService.search(input, launcherMode, shownEntries)

	function shellQuote(value) {
		return `'${value.replace(/'/g, `'\"'\"'`)}'`;
	}

	delegate: Entry {
		id: emojiEntry
		required property var modelData
		name: `:${modelData.primaryName}: ${modelData.emoji}`
		icon: ""
		mode: Mode.emoji
		function shellQuote(value) {
			return `'${value.replace(/'/g, `'\"'\"'`)}'`;
		}
		selectionCallback: SelectionCallback {
			closeLauncher: true
			callback: () => {
				Quickshell.execDetached(["bash", "-lc", `printf '%s' ${emojiEntry.shellQuote(emojiEntry.modelData.emoji)} | wl-copy`]);
			}
		}
	}
}
