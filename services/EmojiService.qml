pragma Singleton

import Quickshell
import Quickshell.Io
import qs.modules.appLauncher
import qs.utils
import QtQuick

Singleton {
	id: root
	readonly property string cacheDir: `${Paths.strip(Paths.data)}/shell`
	readonly property string cachePath: `${root.cacheDir}/discordEmojiMap-canary.min.json`
	readonly property string sourceUrl: "https://emzi0767.mzgit.io/discord-emoji/discordEmojiMap-canary.min.json"
	property var definitions: []

	function normalizeSearchTerm(value) {
		return value.trim().toLowerCase().replace(/^:/, "");
	}

	function loadDefinitionsFromText(text) {
		try {
			const parsed = JSON.parse(text);
			const definitions = parsed.emojiDefinitions || [];
			root.definitions = definitions.map(definition => ({
						emoji: definition.surrogates || "",
						primaryName: definition.primaryName || "",
						search: [definition.primaryName || "", ...(definition.names || [])].join(" ").toLowerCase()
					})).filter(definition => definition.emoji.length > 0 && definition.primaryName.length > 0);
		} catch (error) {
			root.definitions = [];
		}
	}

	function search(query, modeValue, limit) {
		const normalized = root.normalizeSearchTerm(query);
		const emojiMode = modeValue == Mode.emoji;
		const triggered = emojiMode || query.trim().startsWith(":");
		if (!triggered)
			return [];

		if (normalized.length === 0)
			return emojiMode ? root.definitions.slice(0, limit) : [];

		return root.definitions.filter(definition => definition.search.includes(normalized)).slice(0, limit);
	}

	Process {
		id: refreshProcess
		command: ["bash", "-lc", `mkdir -p '${root.cacheDir}' && curl -fsSL '${root.sourceUrl}'`]
		stdout: StdioCollector {
			waitForEnd: true
		}
		stderr: StdioCollector {
			waitForEnd: true
		}
		onExited: exitCode => {
			if (exitCode !== 0)
				return;

			const payload = refreshProcess.stdout.text;
			if (payload.trim().length === 0)
				return;

			cacheFile.setText(payload);
			root.loadDefinitionsFromText(payload);
		}
	}

	FileView {
		id: cacheFile
		path: root.cachePath
		printErrors: false

		onLoaded: root.loadDefinitionsFromText(cacheFile.text())
	}

	Component.onCompleted: {
		refreshProcess.running = true;
	}
}
