pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.utils

Singleton {
	id: root

	readonly property string profilesDir: `${Paths.strip(Paths.home)}/.config/shell/profiles`
	readonly property string hyprMonitorConfigPath: `${Paths.strip(Paths.home)}/.config/hypr/hyprland_monitor.lua`

	property string profileName: ""
	property string loadedProfileName: ""
	property string statusMessage: ""
	property string errorMessage: ""
	property bool busy: false
	property var monitorDrafts: []
	property var savedProfiles: []
	property string pendingProfileFile: ""
	property string deletingProfileFile: ""
	property string pendingProfileAction: ""

	function numericValue(value, fallback): real {
		const parsed = Number(value);
		return isNaN(parsed) ? fallback : parsed;
	}

	function integerValue(value, fallback): int {
		return Math.round(root.numericValue(value, fallback));
	}

	function formatNumber(value): string {
		const rounded = Math.round(value * 100) / 100;
		return Number.isInteger(rounded) ? `${Math.trunc(rounded)}` : `${rounded}`;
	}

	function sanitizeProfileName(name: string): string {
		const cleaned = name.trim().replace(/[^\w.-]+/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "");
		return cleaned.length > 0 ? cleaned : "monitor-profile";
	}

	function cloneDraft(draft: var): var {
		return {
			name: draft.name || "",
			description: draft.description || "",
			enabled: draft.enabled !== false,
			width: root.integerValue(draft.width, 0),
			height: root.integerValue(draft.height, 0),
			refreshRate: root.numericValue(draft.refreshRate, 0),
			x: root.integerValue(draft.x, 0),
			y: root.integerValue(draft.y, 0),
			scale: root.numericValue(draft.scale, 1),
			transform: root.integerValue(draft.transform, 0),
			mirror: draft.mirror || "",
			extraArgs: draft.extraArgs || ""
		};
	}

	function draftFromMonitor(monitor: var): var {
		const ipc = monitor.lastIpcObject || {};
		return root.cloneDraft({
			name: monitor.name,
			description: monitor.description || "",
			enabled: ipc.disabled !== true,
			width: monitor.width || ipc.width || 0,
			height: monitor.height || ipc.height || 0,
			refreshRate: ipc.refreshRate || ipc.refresh || 0,
			x: monitor.x || ipc.x || 0,
			y: monitor.y || ipc.y || 0,
			scale: monitor.scale || ipc.scale || 1,
			transform: ipc.transform || 0,
			mirror: ipc.mirror || "",
			extraArgs: ""
		});
	}

	function monitorNameMap(monitors: var): var {
		const map = ({});
		for (let i = 0; i < monitors.length; i++) {
			const monitor = monitors[i];
			map[monitor.name] = monitor;
		}
		return map;
	}

	function captureCurrentMonitors(): var {
		Hyprland.refreshMonitors();
		const monitors = Hyprland.monitors.values || [];
		return monitors.map(monitor => root.draftFromMonitor(monitor));
	}

	function resetDraftsFromSystem(): void {
		root.monitorDrafts = root.captureCurrentMonitors();
		root.loadedProfileName = "";
		if (root.profileName.trim().length === 0)
			root.profileName = "current";
		root.statusMessage = `Loaded ${root.monitorDrafts.length} monitor${root.monitorDrafts.length === 1 ? "" : "s"} from Hyprland.`;
		root.errorMessage = "";
	}

	function createProfile(): void {
		const now = new Date();
		const stamp = `${now.getFullYear()}-${`${now.getMonth() + 1}`.padStart(2, "0")}-${`${now.getDate()}`.padStart(2, "0")}-${`${now.getHours()}`.padStart(2, "0")}${`${now.getMinutes()}`.padStart(2, "0")}`;
		root.profileName = `profile-${stamp}`;
		root.loadedProfileName = "";
		root.monitorDrafts = root.captureCurrentMonitors();
		root.errorMessage = "";
		root.statusMessage = `Created ${root.profileName} from the current monitor layout.`;
	}

	function mergeWithCurrentMonitors(monitors: var): var {
		const current = root.captureCurrentMonitors();
		const currentMap = root.monitorNameMap(current);
		const merged = [];

		for (let i = 0; i < monitors.length; i++) {
			const saved = root.cloneDraft(monitors[i]);
			if (currentMap[saved.name] !== undefined)
				saved.description = currentMap[saved.name].description || saved.description;
			merged.push(saved);
			delete currentMap[saved.name];
		}

		for (const name in currentMap)
			merged.push(currentMap[name]);

		return merged;
	}

	function setDraftField(name: string, field: string, value: var): void {
		const next = root.monitorDrafts.slice();
		for (let i = 0; i < next.length; i++) {
			if (next[i].name !== name)
				continue;
			const updated = root.cloneDraft(next[i]);
			updated[field] = value;
			next[i] = root.cloneDraft(updated);
			root.monitorDrafts = next;
			return;
		}
	}

	function setDraftFields(name: string, fields: var): void {
		const next = root.monitorDrafts.slice();
		for (let i = 0; i < next.length; i++) {
			if (next[i].name !== name)
				continue;
			const updated = root.cloneDraft(next[i]);
			for (const field in fields)
				updated[field] = fields[field];
			next[i] = root.cloneDraft(updated);
			root.monitorDrafts = next;
			return;
		}
	}

	function profilePayload(): var {
		return {
			name: root.profileName.trim(),
			savedAt: new Date().toISOString(),
			monitors: root.monitorDrafts.map(draft => root.cloneDraft(draft))
		};
	}

	function buildMonitorLine(draft: var): string {
		if (draft.enabled === false)
			return `hl.monitor({output = "${draft.name}", disabled = true })`;

		const resolution = draft.width > 0 && draft.height > 0 ? `${draft.width}x${draft.height}` : "preferred";
		const refreshPart = draft.refreshRate > 0 ? `@${root.formatNumber(draft.refreshRate)}` : "";
		const position = `${draft.x}x${draft.y}`;
		const scale = root.formatNumber(draft.scale > 0 ? draft.scale : 1);
		const extras = [];

		if (draft.transform > 0)
			extras.push("transform", `${draft.transform}`);
		if (draft.mirror.trim().length > 0)
			extras.push("mirror", draft.mirror.trim());
		if (draft.extraArgs.trim().length > 0)
			extras.push(draft.extraArgs.trim());

		return `hl.monitor({output = "${draft.name}", mode = "${resolution}${refreshPart}", position = "${position}", scale = "${scale}${extras.length > 0 ? `,${extras.join(",")}` : ""}"})`;
	}

	function buildHyprlandConfig(): string {
		const lines = ["-- Generated by Quickshell monitor profiles", `-- Profile: ${root.profileName.trim().length > 0 ? root.profileName.trim() : "unnamed"}`];

		for (let i = 0; i < root.monitorDrafts.length; i++)
			lines.push(root.buildMonitorLine(root.monitorDrafts[i]));

		lines.push("");
		return lines.join("\n");
	}

	function saveProfile(): void {
		const trimmed = root.profileName.trim();
		if (trimmed.length === 0) {
			root.errorMessage = "Profile name is required before saving.";
			root.statusMessage = "";
			return;
		}

		root.pendingProfileFile = `${root.sanitizeProfileName(trimmed)}.json`;
		root.busy = true;
		root.errorMessage = "";
		root.pendingProfileAction = "save";
		root.statusMessage = `Saving ${trimmed}…`;
		profileFile.path = `${root.profilesDir}/${root.pendingProfileFile}`;
		profileFile.setText(JSON.stringify(root.profilePayload(), null, 2));
	}

	function applyProfile(): void {
		root.busy = true;
		root.errorMessage = "";
		root.statusMessage = "Writing Hyprland monitor config…";
		hyprConfigFile.path = root.hyprMonitorConfigPath;
		hyprConfigFile.setText(root.buildHyprlandConfig());
	}

	function loadProfile(profileName: string): void {
		root.busy = true;
		root.errorMessage = "";
		root.pendingProfileAction = "load";
		root.pendingProfileFile = profileName;
		root.statusMessage = `Loading ${profileName}…`;
		const path = `${root.profilesDir}/${profileName}`;
		if (profileFile.path === path)
			profileFile.reload();
		else
			profileFile.path = path;
	}

	function deleteProfile(profileFile: string): void {
		root.busy = true;
		root.errorMessage = "";
		root.deletingProfileFile = profileFile;
		root.statusMessage = `Deleting ${profileFile}…`;
		deleteWriter.environment = ({
				QS_TARGET_DIR: root.profilesDir,
				QS_TARGET_FILE: profileFile
			});
		deleteWriter.running = true;
	}

	function refreshSavedProfiles(): void {
		root.errorMessage = "";
		listProfiles.running = true;
	}

	Component.onCompleted: {
		root.resetDraftsFromSystem();
		root.refreshSavedProfiles();
	}

	Process {
		id: listProfiles
		command: ["bash", "-lc", "mkdir -p \"$QS_TARGET_DIR\" && find \"$QS_TARGET_DIR\" -maxdepth 1 -type f -name '*.json' -printf '%f\n' | sort"]
		environment: ({
				QS_TARGET_DIR: root.profilesDir
			})
		stdout: StdioCollector {
			onStreamFinished: {
				root.savedProfiles = text.split("\n").map(line => line.trim()).filter(line => line.length > 0);
			}
		}
		stderr: StdioCollector {
			onStreamFinished: {
				const error = text.trim();
				if (error.length > 0)
					root.errorMessage = error;
			}
		}
		onExited: exitCode => {
			if (exitCode !== 0 && root.errorMessage.length === 0)
				root.errorMessage = `Failed to list saved profiles in ${root.profilesDir}.`;
		}
	}

	Process {
		id: deleteWriter
		command: ["bash", "-lc", "rm -f \"$QS_TARGET_DIR/$QS_TARGET_FILE\""]
		stderr: StdioCollector {
			onStreamFinished: {
				const error = text.trim();
				if (error.length > 0)
					root.errorMessage = error;
			}
		}
		onExited: exitCode => {
			root.busy = false;
			if (exitCode === 0 && root.errorMessage.length === 0) {
				if (root.loadedProfileName === root.deletingProfileFile)
					root.loadedProfileName = "";
				root.statusMessage = `Deleted ${root.deletingProfileFile}.`;
				root.refreshSavedProfiles();
			} else if (root.errorMessage.length === 0) {
				root.errorMessage = `Failed to delete ${root.deletingProfileFile}.`;
				root.statusMessage = "";
			}
			root.deletingProfileFile = "";
		}
	}

	Process {
		id: reloadHyprland
		command: ["hyprctl", "reload"]
		stdout: StdioCollector {}
		stderr: StdioCollector {
			onStreamFinished: {
				const error = text.trim();
				if (error.length > 0)
					root.errorMessage = error;
			}
		}
		onExited: exitCode => {
			root.busy = false;
			if (exitCode === 0 && root.errorMessage.length === 0) {
				root.statusMessage = `Applied monitor rules from ${root.hyprMonitorConfigPath}.`;
			} else if (root.errorMessage.length === 0) {
				root.errorMessage = "Wrote the config, but Hyprland reload failed.";
				root.statusMessage = "";
			}
		}
	}

	FileView {
		id: profileFile
		printErrors: false

		onLoaded: {
			if (root.pendingProfileAction !== "load")
				return;

			try {
				const parsed = JSON.parse(profileFile.text());
				const name = parsed.name || root.pendingProfileFile.replace(/\.json$/, "");
				root.profileName = name;
				root.loadedProfileName = root.pendingProfileFile;
				root.monitorDrafts = root.mergeWithCurrentMonitors(parsed.monitors || []);
				root.statusMessage = `Loaded ${root.loadedProfileName}.`;
				root.errorMessage = "";
			} catch (error) {
				root.errorMessage = `Unable to parse ${root.pendingProfileFile}: ${error}`;
				root.statusMessage = "";
			}

			root.pendingProfileAction = "";
			root.busy = false;
		}

		onLoadFailed: error => {
			if (root.pendingProfileAction !== "load")
				return;

			root.errorMessage = `Unable to load ${root.pendingProfileFile}: ${error}`;
			root.statusMessage = "";
			root.pendingProfileAction = "";
			root.busy = false;
		}

		onSaved: {
			if (root.pendingProfileAction !== "save")
				return;

			root.loadedProfileName = root.pendingProfileFile;
			root.statusMessage = `Saved ${root.pendingProfileFile} in ${root.profilesDir}.`;
			root.errorMessage = "";
			root.pendingProfileAction = "";
			root.busy = false;
			root.refreshSavedProfiles();
		}

		onSaveFailed: error => {
			if (root.pendingProfileAction !== "save")
				return;

			root.errorMessage = `Failed to save ${root.pendingProfileFile}: ${error}`;
			root.statusMessage = "";
			root.pendingProfileAction = "";
			root.busy = false;
		}
	}

	FileView {
		id: hyprConfigFile
		printErrors: false

		onSaved: {
			root.statusMessage = `Wrote ${root.hyprMonitorConfigPath}. Reloading Hyprland…`;
			reloadHyprland.running = true;
		}

		onSaveFailed: error => {
			root.busy = false;
			root.errorMessage = `Failed to write ${root.hyprMonitorConfigPath}: ${error}`;
			root.statusMessage = "";
		}
	}
}
