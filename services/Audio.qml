pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
	id: root
	property bool initialized: false

	readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
		if (!node.isStream && node.isSink) {
			acc.sinks.push(node);
		} else if (node.isStream && node.audio) {
			acc.sources.push(node);
		}
		root.initialized = true;
		return acc;
	}, {
		sources: [],
		sinks: []
	})

	readonly property list<PwNode> sinks: nodes.sinks
	readonly property list<PwNode> sources: nodes.sources

	readonly property PwNode sink: Pipewire.defaultAudioSink
	readonly property PwNode source: Pipewire.defaultAudioSource

	readonly property bool muted: !!sink?.audio?.muted
	readonly property real volume: sink?.audio?.volume ?? 0

	function setVolume(newVolume: real): void {
		if (sink?.ready && sink?.audio) {
			sink.audio.muted = false;
			sink.audio.volume = Math.max(0, Math.min(1, newVolume));
		}
	}

	function incrementVolume(amount: real): void {
		setVolume(volume + amount);
	}

	function decrementVolume(amount: real): void {
		setVolume(volume - amount);
	}

	function setAudioSink(newSink: PwNode): void {
		Pipewire.preferredDefaultAudioSink = newSink;
	}

	function setAudioSource(newSource: PwNode): void {
		Pipewire.preferredDefaultAudioSource = newSource;
	}

	PwObjectTracker {
		objects: [...root.sinks, ...root.sources]
	}
}
