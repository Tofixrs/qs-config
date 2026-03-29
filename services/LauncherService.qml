pragma Singleton

import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.appLauncher
import qs.modules.appLauncher.providers
import qs.utils

Singleton {
	id: root
	property string panelName: "appLauncher"
	property int mode: Mode.all
	property int focusedEntry: 0
	property int shownEntries: 10
	property string query: ""
	property var usageCounts: ({})
	property list<string> knownUnitTokens: ["mm", "millimeter", "millimeters", "cm", "centimeter", "centimeters", "m", "meter", "meters", "km", "kilometer", "kilometers", "in", "inch", "inches", "ft", "foot", "feet", "yd", "yard", "yards", "mi", "mile", "miles", "nmi", "nm", "nauticalmile", "nauticalmiles", "mg", "milligram", "milligrams", "g", "gram", "grams", "kg", "kilogram", "kilograms", "oz", "ounce", "ounces", "lb", "lbs", "pound", "pounds", "ton", "tons", "ml", "milliliter", "milliliters", "l", "liter", "liters", "dl", "cl", "tsp", "tbsp", "cup", "cups", "pt", "pint", "pints", "qt", "quart", "quarts", "gal", "gallon", "gallons", "s", "sec", "secs", "second", "seconds", "min", "mins", "minute", "minutes", "h", "hr", "hrs", "hour", "hours", "day", "days", "week", "weeks", "month", "months", "year", "years", "c", "f", "k", "celsius", "fahrenheit", "kelvin", "mph", "kph", "kmh", "mps", "fps", "knot", "knots", "b", "byte", "bytes", "kb", "mb", "gb", "tb", "kib", "mib", "gib", "tib", "w", "kw", "mw", "gw", "j", "kj", "mj", "gj", "wh", "kwh", "pa", "kpa", "mpa", "bar", "psi", "atm", "deg", "rad", "usd", "eur", "gbp", "pln", "jpy", "cad", "aud", "chf", "cny"]
	readonly property string usagePath: `${Paths.strip(Paths.config)}/qs-shell/launcher-usage.json`
	readonly property string normalizedQuery: root.query.trim()
	readonly property string normalizedCalcValue: root.normalizedCalcQuery()
	readonly property bool explicitCalcQuery: root.normalizedQuery.startsWith("=")
	readonly property bool modeSearchQuery: root.normalizedQuery.startsWith(">")
	readonly property bool computeIntent: root.isMathLikeQuery()

	function normalizedCalcQuery() {
		return root.normalizedQuery.replace(/^=/, "").replace(/\.$/, "").trim();
	}

	function hasKnownUnitToken(query) {
		const tokens = query.toLowerCase().split(/[^a-z]+/).filter(token => token.length > 0);
		for (let i = 0; i < tokens.length; i++) {
			if (root.knownUnitTokens.includes(tokens[i]))
				return true;
		}

		return false;
	}

	function isMathLikeQuery() {
		if (root.mode == Mode.calc || root.explicitCalcQuery)
			return root.normalizedCalcValue.length > 0;
		if (root.modeSearchQuery)
			return false;

		const query = root.normalizedCalcValue.toLowerCase();
		if (query.length === 0)
			return false;

		const compact = query.replace(/\s+/g, "");
		const startsWithQuantity = /^[+-]?(\d+([.,]\d+)?|[.,]\d+)/.test(query);
		const hasLetters = /[a-z]/.test(compact);
		const hasConversionKeyword = /\b(to|in|as)\b/.test(query);
		const hasKnownUnit = root.hasKnownUnitToken(query);
		const looksLikeUnitQuery = startsWithQuantity && hasKnownUnit;
		const hasEquation = compact.includes("=");
		const functionPattern = /\b(sqrt|cbrt|root|abs|round|floor|ceil|trunc|sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|log|ln|exp|min|max|avg|mean)\b/g;
		const functionMatchPattern = /\b(sqrt|cbrt|root|abs|round|floor|ceil|trunc|sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|log|ln|exp|min|max|avg|mean)\b/;
		const constantPattern = /\b(pi|e)\b/g;
		const stripped = compact.replace(functionPattern, "").replace(constantPattern, "");

		if (looksLikeUnitQuery && !hasEquation)
			return true;

		if (hasEquation) {
			const letters = compact.match(/[a-z]/g) || [];
			const uniqueLetters = ({});
			for (let i = 0; i < letters.length; i++)
				uniqueLetters[letters[i]] = true;
			const uniqueLetterCount = Object.keys(uniqueLetters).length;
			if (uniqueLetterCount === 0 || uniqueLetterCount > 1)
				return false;
		} else if (/[a-df-z]/.test(stripped)) {
			return false;
		}

		const hasNumber = /\d/.test(compact);
		const hasConstant = /\b(pi|e)\b/.test(compact);
		const hasFunction = functionMatchPattern.test(query);
		const hasVariable = hasLetters;
		const hasOperator = /[+\-*/%^(),=]/.test(compact) || compact.includes("**") || hasConversionKeyword;
		const looksLikeExpression = hasFunction || hasOperator;

		if (hasEquation)
			return hasVariable && (hasNumber || hasConstant);

		return looksLikeExpression && (hasNumber || hasConstant);
	}

	function intentRank(entry) {
		if (root.mode != Mode.all)
			return 1;
		if (root.computeIntent)
			return entry.mode == Mode.calc ? 0 : 1;
		return entry.mode == Mode.calc ? 2 : 1;
	}

	function scoreFor(entry) {
		if (!entry || !entry.usageId || !(entry.usageId in root.usageCounts))
			return 0;

		const score = Number(root.usageCounts[entry.usageId]);
		return isNaN(score) ? 0 : score;
	}

	function matchRank(entry) {
		const name = entry.name.toLowerCase();
		const normalizedQuery = root.query.trim().toLowerCase();
		if (normalizedQuery.length === 0)
			return 2;
		if (name === normalizedQuery)
			return 0;
		if (name.startsWith(normalizedQuery))
			return 1;
		return 2;
	}

	function compareEntries(a, b) {
		if (a.mode == Mode.clipboard && b.mode == Mode.clipboard)
			return a.sortIndex - b.sortIndex;

		const intentDiff = root.intentRank(a) - root.intentRank(b);
		if (intentDiff !== 0)
			return intentDiff;

		const matchDiff = root.matchRank(a) - root.matchRank(b);
		if (matchDiff !== 0)
			return matchDiff;

		const usageDiff = root.scoreFor(b) - root.scoreFor(a);
		if (usageDiff !== 0)
			return usageDiff;

		if (a.mode != b.mode)
			return a.mode - b.mode;

		return a.name.localeCompare(b.name);
	}

	function clampFocusedEntry() {
		if (root.filteredEntries.length === 0) {
			root.focusedEntry = 0;
			return;
		}

		if (root.focusedEntry >= root.filteredEntries.length)
			root.focusedEntry = 0;
		if (root.focusedEntry < 0)
			root.focusedEntry = 0;
	}

	function recordUsage(entry) {
		if (!entry || !entry.usageId)
			return;

		const nextCounts = ({});
		for (const key in root.usageCounts)
			nextCounts[key] = root.usageCounts[key];
		nextCounts[entry.usageId] = root.scoreFor(entry) + 1;
		root.usageCounts = nextCounts;
		usageFile.setText(JSON.stringify(nextCounts, null, 2));
	}

	function moveFocus(delta: int) {
		if (root.filteredEntries.length === 0) {
			root.focusedEntry = 0;
			return;
		}

		root.focusedEntry += delta;
		if (root.focusedEntry < 0) {
			root.focusedEntry = 0;
		} else if (root.focusedEntry >= root.filteredEntries.length) {
			root.focusedEntry = 0;
		}
	}

	function activateFocused() {
		const entry = root.filteredEntries[root.focusedEntry];
		if (!entry)
			return;

		const cb = entry.selectionCallback;
		const entrySnapshot = {
			name: entry.name,
			icon: entry.icon,
			mode: entry.mode,
			usageId: entry.usageId,
			payload: entry.payload,
			result: entry.result !== undefined && entry.result !== null ? `${entry.result}` : ""
		};
		root.recordUsage(entry);

		if (cb.swapToMode != null) {
			root.mode = cb.swapToMode;
			root.query = "";
		}
		if (cb.callback != null) {
			cb.callback(entrySnapshot);
		}
		if (cb.closeLauncher)
			root.hide();
	}

	function setMode(modeValue: int) {
		root.mode = modeValue !== undefined && modeValue !== null ? modeValue : Mode.all;
		root.clampFocusedEntry();
	}

	function show(modeValue: int) {
		root.setMode(modeValue);
		Visibilities.set(root.panelName, true);
	}

	function hide() {
		root.focusedEntry = 0;
		root.query = "";
		root.mode = Mode.all;
		Visibilities.set(root.panelName, false);
	}

	function toggle(modeValue: int) {
		if (Visibilities.is(root.panelName)) {
			root.hide();
			return;
		}
		root.show(modeValue);
	}

	Apps {
		id: appProvider
	}
	Modes {
		id: modeProvider
	}
	Calc {
		id: calcProvider
		input: root.query
		active: root.mode == Mode.calc || root.computeIntent
	}
	Emoji {
		id: emojiProvider
		input: root.query
		launcherMode: root.mode
	}
	Clipboard {
		id: clipboardProvider
		input: root.query
		active: root.mode == Mode.clipboard
	}
	PowerActions {
		id: powerActions
	}

	readonly property list<Entry> entries: [...appProvider.instances, ...modeProvider.instances, ...powerActions.instances, ...emojiProvider.instances, ...clipboardProvider.instances, calcProvider].sort((a, b) => root.compareEntries(a, b))

	property list<Entry> filteredEntries: root.entries.filter(v => {
		if (root.mode == Mode.calc && v.mode == Mode.calc)
			return v.name.trim().length > 0;
		if (v.mode == Mode.calc && root.mode == Mode.all)
			return root.computeIntent && v.name.trim().length > 0;
		if (v.mode == Mode.calc && v.name.trim().length == 0)
			return false;
		if (v.mode == Mode.clipboard && root.mode == Mode.all)
			return false;
		if (v.mode == Mode.clipboard && v.name.trim().length == 0)
			return false;
		const name = v.name.toLowerCase();
		const normalizedQuery = root.normalizedQuery.toLowerCase();
		if (normalizedQuery[0] == ">" && root.mode == Mode.all)
			return v.mode == Mode.modes && name.includes(normalizedQuery.slice(1));

		return (v.mode == root.mode || root.mode == Mode.all) && name.includes(normalizedQuery);
	}).slice(0, root.shownEntries)

	onFilteredEntriesChanged: root.clampFocusedEntry()
	onQueryChanged: root.clampFocusedEntry()

	FileView {
		id: usageFile
		path: root.usagePath
		printErrors: false

		onLoaded: {
			try {
				const parsed = JSON.parse(usageFile.text());
				root.usageCounts = parsed && typeof parsed === "object" ? parsed : ({});
			} catch (error) {
				root.usageCounts = ({});
			}
		}

		onLoadFailed: error => {
			root.usageCounts = ({});
		}
	}

	IpcHandler {
		target: "launcher"
		function hide() {
			root.hide();
		}

		function toggle(modeValue: int) {
			root.toggle(modeValue);
		}

		function setMode(modeValue: int) {
			root.setMode(modeValue);
		}
	}
}
