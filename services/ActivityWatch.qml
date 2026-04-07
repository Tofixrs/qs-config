pragma Singleton

import QtQuick
import Quickshell

Singleton {
	id: root

	property string baseUrl: "http://127.0.0.1:5600/api/0"
	property string windowBucketId: ""
	property string afkBucketId: ""
	property string currentApp: ""
	property string currentTitle: ""
	property var classes: []
	property var categories: []
	property real totalDuration: 0
	property bool loading: false
	property string error: ""
	property date lastUpdated: new Date(0)

	readonly property string currentLabel: root.currentApp.length > 0 ? root.currentApp : "No active window"
	readonly property string subtitle: root.currentTitle.length > 0 ? root.currentTitle : (root.error.length > 0 ? root.error : "ActivityWatch idle")
	readonly property string totalLabel: root.formatDuration(root.totalDuration)

	function refresh(): void {
		root.loading = true;
		root.error = "";
		root.fetchBuckets();
	}

	function fetchJson(path: string, onSuccess: var, onFailure: var): void {
		const request = new XMLHttpRequest();
		request.onreadystatechange = function () {
			if (request.readyState !== XMLHttpRequest.DONE)
				return;

			if (request.status >= 200 && request.status < 300) {
				try {
					onSuccess(JSON.parse(request.responseText));
				} catch (error) {
					onFailure(`Invalid ActivityWatch response: ${error}`);
				}
			} else {
				onFailure(`ActivityWatch unavailable (HTTP ${request.status || "?"})`);
			}
		};
		request.open("GET", `${root.baseUrl}${path}`);
		request.setRequestHeader("Accept", "application/json");
		request.send();
	}

	function postJson(path: string, payload: var, onSuccess: var, onFailure: var): void {
		const request = new XMLHttpRequest();
		request.onreadystatechange = function () {
			if (request.readyState !== XMLHttpRequest.DONE)
				return;

			if (request.status >= 200 && request.status < 300) {
				try {
					onSuccess(JSON.parse(request.responseText));
				} catch (error) {
					onFailure(`Invalid ActivityWatch response: ${error}`);
				}
			} else {
				onFailure(`ActivityWatch query failed (HTTP ${request.status || "?"})`);
			}
		};
		request.open("POST", `${root.baseUrl}${path}`);
		request.setRequestHeader("Accept", "application/json");
		request.setRequestHeader("Content-Type", "application/json");
		request.send(JSON.stringify(payload));
	}

	function fetchBuckets(): void {
		root.fetchJson("/buckets/", payload => {
			const bucketIds = Object.keys(payload || {});
			const windowBucket = bucketIds.find(id => id.startsWith("aw-watcher-window_")) || "";
			const afkBucket = bucketIds.find(id => id.startsWith("aw-watcher-afk_")) || "";
			if (windowBucket.length === 0) {
				root.loading = false;
				root.windowBucketId = "";
				root.afkBucketId = "";
				root.currentApp = "";
				root.currentTitle = "";
				root.categories = [];
				root.totalDuration = 0;
				root.error = "No aw-watcher-window bucket found";
				return;
			}
			if (afkBucket.length === 0) {
				root.loading = false;
				root.windowBucketId = windowBucket;
				root.afkBucketId = "";
				root.error = "No aw-watcher-afk bucket found";
				return;
			}

			root.windowBucketId = windowBucket;
			root.afkBucketId = afkBucket;
			root.fetchCurrentWindow();
			root.fetchClasses();
		}, reason => {
			root.loading = false;
			root.error = reason;
		});
	}

	function fetchCurrentWindow(): void {
		root.fetchJson(`/buckets/${encodeURIComponent(root.windowBucketId)}/events?limit=1`, payload => {
			const events = Array.isArray(payload) ? payload : [];
			const latest = events.length > 0 ? events[events.length - 1] : null;
			root.currentApp = latest && latest.data && latest.data.app ? `${latest.data.app}` : "";
			root.currentTitle = latest && latest.data && latest.data.title ? `${latest.data.title}` : "";
			root.lastUpdated = new Date();
			root.loading = false;
		}, reason => {
			root.loading = false;
			root.error = reason;
		});
	}

	function fetchClasses(): void {
		root.fetchJson("/settings/classes", payload => {
			root.classes = Array.isArray(payload) ? payload.map(entry => [entry.name, entry.rule]) : [];
			root.fetchTodaySummary();
		}, reason => {
			root.loading = false;
			root.error = reason;
		});
	}

	function buildCategoryQuery(): var {
		const lines = [`events = flood(query_bucket(find_bucket("${root.escapeDoubleQuotes(root.windowBucketId)}")));`, `not_afk = flood(query_bucket(find_bucket("${root.escapeDoubleQuotes(root.afkBucketId)}")));`, 'not_afk = filter_keyvals(not_afk, "status", ["not-afk"]);', "events = filter_period_intersect(events, not_afk);", `events = categorize(events, ${root.classesJson()});`, 'cat_events = sort_by_duration(merge_events_by_keys(events, ["$category"]));', "duration = sum_durations(events);", 'RETURN = { "cat_events": cat_events, "duration": duration };'];
		return lines;
	}

	function fetchTodaySummary(): void {
		const now = new Date();
		const start = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString();
		const end = now.toISOString();

		root.postJson("/query/", {
			timeperiods: [`${start}/${end}`],
			query: root.buildCategoryQuery()
		}, payload => {
			const result = Array.isArray(payload) && payload.length > 0 ? payload[0] : {};
			const categoryEvents = Array.isArray(result.cat_events) ? result.cat_events : [];
			const total = root.parseDuration(result.duration);
			const nextCategories = [];

			for (let i = 0; i < categoryEvents.length; i++) {
				const event = categoryEvents[i];
				const duration = root.parseDuration(event && event.duration);
				const label = root.categoryLabel(event);
				if (duration <= 0 || label.length === 0)
					continue;
				nextCategories.push({
					name: label,
					duration: duration,
					ratio: total > 0 ? duration / total : 0
				});
			}

			root.totalDuration = total;
			root.categories = nextCategories.slice(0, 6);
			root.loading = false;
		}, reason => {
			root.loading = false;
			root.error = reason;
		});
	}

	function classesJson(): string {
		const json = JSON.stringify(root.classes);
		return json.replace(/\\\\/g, "\\");
	}

	function escapeDoubleQuotes(value: string): string {
		return `${value}`.replace(/"/g, "\\\"");
	}

	function parseDuration(value: var): real {
		if (typeof value === "number")
			return value;
		if (typeof value === "string") {
			const numeric = Number(value);
			if (!isNaN(numeric))
				return numeric;
			const parts = value.split(":").map(Number);
			if (parts.length === 3 && parts.every(part => !isNaN(part)))
				return (parts[0] * 3600) + (parts[1] * 60) + parts[2];
		}
		return 0;
	}

	function categoryLabel(event: var): string {
		const value = event && event.data ? event.data["$category"] : null;
		if (Array.isArray(value))
			return value.join(" / ");
		return value ? `${value}` : "Uncategorized";
	}

	function formatDuration(seconds: real): string {
		const totalSeconds = Math.max(0, Math.round(seconds));
		const hours = Math.floor(totalSeconds / 3600);
		const minutes = Math.floor((totalSeconds % 3600) / 60);
		if (hours > 0)
			return `${hours}h ${minutes}m`;
		return `${minutes}m`;
	}

	Component.onCompleted: refresh()

	Timer {
		interval: 15000
		running: true
		repeat: true
		onTriggered: root.refresh()
	}
}
