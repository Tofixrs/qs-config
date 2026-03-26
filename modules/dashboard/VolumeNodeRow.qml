import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.config

SurfaceCard {
	id: root

	required property var node
	property string title: ""
	property string subtitle: ""
	property string icon: "volume_up"
	property bool selected: false
	property bool showSelectButton: false
	property bool showMuteButton: true

	signal selectNode

	readonly property var audio: root.node ? root.node.audio : null
	readonly property real volume: root.audio ? root.audio.volume : 0
	readonly property bool muted: root.audio ? root.audio.muted : false

	cardColor: root.selected ? Theme.hover : Theme.foreground2
	padding: 10
	contentSpacing: 8
	clip: true

	ColumnLayout {
		Layout.fillWidth: true
		spacing: 8

		RowLayout {
			Layout.fillWidth: true
			spacing: 8
			clip: true

			MaterialIcon {
				text: root.icon
				font.pointSize: 16
				color: root.muted ? Theme.inactive : Theme.active
			}

			ColumnLayout {
				Layout.fillWidth: true
				spacing: 2
				clip: true

				MText {
					Layout.fillWidth: true
					text: root.title
					font.pointSize: 11
					wrapMode: Text.Wrap
					maximumLineCount: 2
				}

				MText {
					Layout.fillWidth: true
					text: root.subtitle
					color: Theme.inactive
					font.pointSize: 9
					visible: root.subtitle.length > 0
					wrapMode: Text.Wrap
					maximumLineCount: 2
				}
			}

			Item {
				Layout.fillWidth: true
			}

			PillButton {
				visible: root.showSelectButton
				text: root.selected ? "Active" : "Use"
				active: root.selected
				baseColor: Theme.background
				horizontalPadding: 12
				verticalPadding: 6
				onClick: root.selectNode()
			}

			PillButton {
				visible: root.showMuteButton
				text: root.muted ? "Unmute" : "Mute"
				active: root.muted
				baseColor: Theme.background
				horizontalPadding: 12
				verticalPadding: 6
				disabled: !root.audio
				onClick: {
					if (root.audio)
						root.audio.muted = !root.audio.muted;
				}
			}
		}

		VolumeSlider {
			Layout.fillWidth: true
			enabled: !!root.audio
			value: root.volume
			onMoved: {
				if (root.audio)
					root.audio.volume = value;
			}
		}

		MText {
			text: `${Math.round(root.volume * 100)}%${root.muted ? " • muted" : ""}`
			color: Theme.inactive
			font.pointSize: 9
		}
	}
}
