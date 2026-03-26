import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.config
import qs.widgets

RowLayout {
	id: volumeDisplayRow

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var audio: sink ? sink.audio : null
	readonly property real volume: audio ? audio.volume : 0
	readonly property bool muted: audio ? audio.muted : false
	readonly property real progress: muted ? 0 : Math.max(0, Math.min(1, volume))
	readonly property string iconName: {
		if (muted || progress <= 0)
			return "volume_off";
		if (progress < 0.34)
			return "volume_down";
		if (progress < 0.67)
			return "volume_up";
		return "volume_up";
	}

	spacing: 0

	onProgressChanged: volumeRing.requestPaint()
	onMutedChanged: volumeRing.requestPaint()

	PwObjectTracker {
		objects: [volumeDisplayRow.sink]
	}

	Item {
		implicitWidth: 24
		implicitHeight: 24
		Layout.preferredWidth: implicitWidth
		Layout.preferredHeight: implicitHeight

		Canvas {
			id: volumeRing
			anchors.fill: parent
			antialiasing: true
			onWidthChanged: requestPaint()
			onHeightChanged: requestPaint()

			onPaint: {
				const ctx = getContext("2d");
				const size = Math.min(width, height);
				const center = size / 2;
				const radius = (size / 2) - 2;
				const startAngle = -Math.PI / 2;
				const endAngle = startAngle + (Math.PI * 2 * volumeDisplayRow.progress);

				ctx.reset();
				ctx.clearRect(0, 0, width, height);
				ctx.lineWidth = 2;
				ctx.lineCap = "round";

				ctx.strokeStyle = Theme.hover;
				ctx.beginPath();
				ctx.arc(center, center, radius, 0, Math.PI * 2, false);
				ctx.stroke();

				if (volumeDisplayRow.progress > 0) {
					ctx.strokeStyle = volumeDisplayRow.muted ? Theme.inactive : Theme.active;
					ctx.beginPath();
					ctx.arc(center, center, radius, startAngle, endAngle, false);
					ctx.stroke();
				}
			}
		}

		MaterialIcon {
			anchors.centerIn: parent
			text: volumeDisplayRow.iconName
			font.pointSize: 13
			color: volumeDisplayRow.muted ? Theme.inactive : Theme.text
		}
	}
}
