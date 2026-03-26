import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import qs.modules.dashboard
import qs.widgets
import qs.config

SectionCard {
	id: root

	readonly property real maxListHeight: 180
	readonly property var defaultSink: Pipewire.defaultAudioSink
	readonly property var defaultAudio: root.defaultSink ? root.defaultSink.audio : null
	readonly property bool muted: root.defaultAudio ? root.defaultAudio.muted : false
	readonly property real volume: root.defaultAudio ? root.defaultAudio.volume : 0
	readonly property var outputNodes: Pipewire.nodes.values.filter(node => node && node.audio && node.isSink && !node.isStream)
	readonly property var appNodes: Pipewire.nodes.values.filter(node => node && node.audio && node.isSink && node.isStream)

	function nodeTitle(node: var): string {
		if (!node)
			return "Unknown";
		if (node.description && node.description.length > 0)
			return node.description;
		if (node.nickname && node.nickname.length > 0)
			return node.nickname;
		if (node.properties && node.properties["application.name"])
			return node.properties["application.name"];
		return node.name || "Unknown";
	}

	function nodeSubtitle(node: var): string {
		if (!node || !node.properties)
			return "";
		return node.properties["node.name"] || node.properties["media.class"] || "";
	}

	function appSubtitle(node: var): string {
		if (!node || !node.properties)
			return "";
		return node.properties["media.name"] || node.properties["application.process.binary"] || node.properties["media.class"] || "";
	}

	PwObjectTracker {
		objects: [root.defaultSink, ...root.outputNodes, ...root.appNodes]
	}

	headerItem: Component {
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 8

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				IconButton {
					icon: root.muted ? "volume_off" : (root.volume > 0.5 ? "volume_up" : "volume_down")
					iconPointSize: 18
					iconColor: root.muted ? Theme.inactive : Theme.active
					acceptedButtons: Qt.RightButton
					onClick: event => {
						if (event.button === Qt.RightButton)
							root.expanded = !root.expanded;
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2

					MText {
						text: root.defaultSink ? root.nodeTitle(root.defaultSink) : "Volume"
						font.pointSize: 12
					}

					MText {
						text: root.defaultSink ? `${Math.round(root.volume * 100)}%${root.muted ? " • muted" : ""}` : "No output"
						color: Theme.inactive
						font.pointSize: 10
					}
				}

				Item {
					Layout.fillWidth: true
				}

				PillButton {
					text: root.muted ? "Unmute" : "Mute"
					active: root.muted
					baseColor: Theme.foreground2
					disabled: !root.defaultAudio
					onClick: {
						if (root.defaultAudio)
							root.defaultAudio.muted = !root.defaultAudio.muted;
					}
				}

				IconButton {
					diameter: 28
					icon: root.expanded ? "expand_less" : "expand_more"
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					onClick: root.expanded = !root.expanded
				}
			}

			VolumeSlider {
				Layout.fillWidth: true
				enabled: !!root.defaultAudio
				value: root.volume
				onMoved: {
					if (root.defaultAudio)
						root.defaultAudio.volume = value;
				}
			}

			Item {
				Layout.fillWidth: true
				implicitHeight: 4
			}
		}
	}

	ColumnLayout {
		Layout.fillWidth: true
		spacing: 8

		MText {
			text: "Outputs"
			font.pointSize: 11
		}

		Flickable {
			id: outputViewport
			Layout.fillWidth: true
			Layout.preferredHeight: Math.min(outputListContent.implicitHeight, root.maxListHeight)
			contentWidth: width
			contentHeight: outputListContent.implicitHeight
			boundsBehavior: Flickable.StopAtBounds
			clip: true
			interactive: outputViewport.contentHeight > outputViewport.height

			ScrollBar.vertical: ScrollBar {
				active: outputViewport.interactive
				policy: outputViewport.contentHeight > outputViewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
			}

			Column {
				id: outputListContent
				width: outputViewport.width
				spacing: 6

				Repeater {
					model: root.outputNodes

					delegate: VolumeNodeRow {
						required property var modelData
						width: outputViewport.width
						node: modelData
						title: root.nodeTitle(modelData)
						subtitle: root.nodeSubtitle(modelData)
						icon: "speaker"
						selected: modelData === root.defaultSink
						showSelectButton: true
						onSelectNode: Pipewire.preferredDefaultAudioSink = modelData
					}
				}
			}
		}

		MText {
			text: "App Mixer"
			font.pointSize: 11
		}

		Flickable {
			id: appViewport
			Layout.fillWidth: true
			Layout.preferredHeight: Math.min(appListContent.implicitHeight, root.maxListHeight)
			contentWidth: width
			contentHeight: appListContent.implicitHeight
			boundsBehavior: Flickable.StopAtBounds
			clip: true
			interactive: appViewport.contentHeight > appViewport.height

			ScrollBar.vertical: ScrollBar {
				active: appViewport.interactive
				policy: appViewport.contentHeight > appViewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
			}

			Column {
				id: appListContent
				width: appViewport.width
				spacing: 6

				Repeater {
					model: root.appNodes

					delegate: VolumeNodeRow {
						required property var modelData
						width: appViewport.width
						node: modelData
						title: root.nodeTitle(modelData)
						subtitle: root.appSubtitle(modelData)
						icon: "music_note"
						showSelectButton: false
					}
				}
			}
		}
	}
}
