import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.modules.dashboard
import qs.widgets
import qs.config

SectionCard {
	id: root

	readonly property var players: Mpris.players.values
	readonly property var activePlayer: root.pickActivePlayer()
	readonly property bool hasPlayer: !!root.activePlayer

	function pickActivePlayer() {
		const allPlayers = root.players || [];
		for (let i = 0; i < allPlayers.length; i++) {
			if (allPlayers[i] && allPlayers[i].isPlaying)
				return allPlayers[i];
		}

		return allPlayers.length > 0 ? allPlayers[0] : null;
	}

	function playbackLabel(player: var): string {
		if (!player)
			return "No active players";
		if (player.isPlaying)
			return "Playing";
		return player.trackTitle.length > 0 ? "Paused" : "Idle";
	}

	function subtitle(player: var): string {
		if (!player)
			return "Start playback in an MPRIS-capable app";

		const parts = [];
		if (player.trackArtist && player.trackArtist.length > 0)
			parts.push(player.trackArtist);
		if (player.trackAlbum && player.trackAlbum.length > 0)
			parts.push(player.trackAlbum);
		if (parts.length > 0)
			return parts.join(" • ");

		return player.identity || "Unknown player";
	}

	function positionLabel(value: real): string {
		const totalSeconds = Math.max(0, Math.floor(value || 0));
		const minutes = Math.floor(totalSeconds / 60);
		const seconds = totalSeconds % 60;
		return `${minutes}:${seconds.toString().padStart(2, "0")}`;
	}

	function artUrl(player: var): string {
		if (!player)
			return "";
		if (player.trackArtUrl && `${player.trackArtUrl}`.length > 0)
			return `${player.trackArtUrl}`;
		if (player.metadata && player.metadata["mpris:artUrl"])
			return `${player.metadata["mpris:artUrl"]}`;
		return "";
	}

	Timer {
		running: root.hasPlayer && root.activePlayer.isPlaying
		interval: 1000
		repeat: true
		onTriggered: {
			if (root.hasPlayer)
				root.activePlayer.positionChanged();
		}
	}

	headerItem: Component {
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 10

			RowLayout {
				Layout.fillWidth: true
				spacing: 10

				Rectangle {
					Layout.preferredWidth: 54
					Layout.preferredHeight: 54
					radius: 12
					color: Theme.foreground2
					border.width: 1
					border.color: Theme.hover
					clip: true

					Image {
						id: art
						anchors.fill: parent
						source: root.artUrl(root.activePlayer)
						fillMode: Image.PreserveAspectCrop
						asynchronous: true
						cache: false
						visible: status === Image.Ready
					}

					MaterialIcon {
						anchors.centerIn: parent
						text: "music_note"
						font.pointSize: 22
						color: Theme.inactive
						visible: !art.visible
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2

					MText {
						Layout.fillWidth: true
						text: root.hasPlayer ? (root.activePlayer.trackTitle || "Unknown Title") : "Media"
						font.pointSize: 12
						wrapMode: Text.NoWrap
						elide: Text.ElideRight
					}

					MText {
						Layout.fillWidth: true
						text: root.subtitle(root.activePlayer)
						color: Theme.inactive
						font.pointSize: 10
						wrapMode: Text.NoWrap
						elide: Text.ElideRight
					}

					MText {
						Layout.fillWidth: true
						text: root.hasPlayer ? `${root.playbackLabel(root.activePlayer)} • ${root.activePlayer.identity || "Unknown player"}` : "No active players"
						color: Theme.inactive
						font.pointSize: 10
						wrapMode: Text.NoWrap
						elide: Text.ElideRight
					}
				}

				PillButton {
					text: "Open"
					baseColor: Theme.foreground2
					disabled: !root.hasPlayer || !root.activePlayer.canRaise
					onClick: root.activePlayer.raise()
				}
			}

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				IconButton {
					icon: "skip_previous"
					iconPointSize: 18
					enabled: root.hasPlayer && root.activePlayer.canGoPrevious
					onClick: root.activePlayer.previous()
				}

				IconButton {
					icon: root.hasPlayer && root.activePlayer.isPlaying ? "pause" : "play_arrow"
					iconPointSize: 20
					enabled: root.hasPlayer && root.activePlayer.canTogglePlaying
					onClick: root.activePlayer.togglePlaying()
				}

				IconButton {
					icon: "skip_next"
					iconPointSize: 18
					enabled: root.hasPlayer && root.activePlayer.canGoNext
					onClick: root.activePlayer.next()
				}

				Item {
					Layout.fillWidth: true
				}

				MText {
					text: root.hasPlayer ? `${root.positionLabel(root.activePlayer.position)} / ${root.positionLabel(root.activePlayer.length)}` : ""
					color: Theme.inactive
					font.pointSize: 10
				}
			}

			Rectangle {
				Layout.fillWidth: true
				implicitHeight: 6
				radius: 3
				color: Theme.foreground2

				Rectangle {
					anchors.left: parent.left
					anchors.verticalCenter: parent.verticalCenter
					implicitHeight: parent.implicitHeight
					width: {
						if (!root.hasPlayer || root.activePlayer.length <= 0)
							return 0;
						return Math.max(0, Math.min(parent.width, (root.activePlayer.position / root.activePlayer.length) * parent.width));
					}
					radius: 3
					color: Theme.active
				}
			}
		}
	}
}
