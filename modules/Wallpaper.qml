import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.widgets
import qs.services
import qs.utils
import QtQuick.Layouts

PWindow {
	id: window
	name: "wallpaper"

	required property ShellScreen s
	screen: s

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Background

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}
	Image {
		id: image
		anchors.fill: parent
		source: Qt.resolvedUrl(Paths.home + "/wallpaper.png")
	}

	ColumnLayout {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 48

		Item {
			implicitHeight: clockText.height
			implicitWidth: clockText.width
			MText {
				id: clockShadow
				text: Time.format("HH:mm:ss")
				font.pointSize: 72
				font.family: Theme.font
				color: "#000000"
				x: 5
				y: 5
			}

			MText {
				id: clockText
				text: Time.format("HH:mm:ss")
				font.pointSize: 72
				font.family: Theme.font
				color: Theme.text
			}
		}
		Item {
			implicitHeight: dateText.height
			implicitWidth: parent.width
			MText {
				id: dateShadow
				text: Time.format("dddd, MMMM d")
				font.pointSize: 22
				font.family: Theme.font
				color: "#000000"
				y: 4
				anchors.horizontalCenterOffset: 4
				anchors.horizontalCenter: parent.horizontalCenter
			}

			MText {
				id: dateText
				text: Time.format("dddd, MMMM d")
				font.pointSize: 22
				font.family: Theme.font
				color: Theme.text
				anchors.horizontalCenter: parent.horizontalCenter
			}
		}

		SurfaceCard {
			id: weatherContainer

			RowLayout {
				spacing: 10

				MaterialIcon {
					id: weatherIcon
					text: Weather.currentIcon
					smooth: true
				}

				ColumnLayout {
					MText {
						text: Weather.currentTemp ? `${Weather.currentTemp}°` : "--"
						font.pointSize: 24
						font.family: Theme.font
						color: Theme.text
						Layout.alignment: Qt.AlignLeft
					}

					MText {
						text: Weather.currentCondition && Weather.currentCondition.weatherDesc && Weather.currentCondition.weatherDesc.length > 0 ? Weather.currentCondition.weatherDesc[0].value : ""
						font.pointSize: 12
						color: Theme.inactive
						Layout.alignment: Qt.AlignLeft
					}
				}
				Item {
					Layout.fillWidth: true
				}

				IconButton {
					diameter: 48
					icon: "refresh"
					iconPointSize: 32
					onClick: Weather.refreshCurrent()
				}
			}
			MText {
				text: Weather.error.length > 0 ? `Unable to load weather (${Weather.error})` : ""
				font.pointSize: 10
				color: Theme.deny
				visible: Weather.error.length > 0
			}
		}
	}

	Timer {
		interval: 600000
		repeat: true
		running: true
		onTriggered: Weather.refreshCurrent()
	}

	Component.onCompleted: {
		Weather.refreshCurrent();
	}
}
