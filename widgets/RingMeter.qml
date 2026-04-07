import QtQuick
import qs.config
import qs.widgets

Item {
	id: root

	property real progress: 0
	property color progressColor: Theme.active
	property color trackColor: Theme.hover
	property string icon: ""
	property string valueText: ""
	property string label: ""
	property int diameter: 72

	implicitWidth: diameter
	implicitHeight: diameter + labelText.implicitHeight + 24

	onProgressChanged: ring.requestPaint()

	Item {
		width: root.diameter
		height: root.diameter
		anchors.horizontalCenter: parent.horizontalCenter

		Canvas {
			id: ring
			anchors.fill: parent
			antialiasing: true
			onWidthChanged: requestPaint()
			onHeightChanged: requestPaint()

			onPaint: {
				const ctx = getContext("2d");
				const size = Math.min(width, height);
				const center = size / 2;
				const radius = (size / 2) - 4;
				const startAngle = -Math.PI / 2;
				const endAngle = startAngle + (Math.PI * 2 * Math.max(0, Math.min(1, root.progress)));

				ctx.reset();
				ctx.clearRect(0, 0, width, height);
				ctx.lineWidth = 5;
				ctx.lineCap = "round";

				ctx.strokeStyle = root.trackColor;
				ctx.beginPath();
				ctx.arc(center, center, radius, 0, Math.PI * 2, false);
				ctx.stroke();

				if (root.progress > 0) {
					ctx.strokeStyle = root.progressColor;
					ctx.beginPath();
					ctx.arc(center, center, radius, startAngle, endAngle, false);
					ctx.stroke();
				}
			}
		}

		Column {
			anchors.centerIn: parent
			spacing: -1

			MaterialIcon {
				anchors.horizontalCenter: parent.horizontalCenter
				text: root.icon
				font.pointSize: 18
				color: Theme.text
			}

			MText {
				anchors.horizontalCenter: parent.horizontalCenter
				text: root.valueText
				font.pointSize: 9
			}
		}
	}

	MText {
		id: labelText
		anchors.top: parent.top
		anchors.topMargin: root.diameter + 8
		anchors.horizontalCenter: parent.horizontalCenter
		text: root.label
		font.pointSize: 10
		color: Theme.inactive
	}
}
