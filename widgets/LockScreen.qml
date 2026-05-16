pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import qs.config
import qs.services
import qs.widgets

Rectangle {
	id: root

	readonly property bool busyAuthenticating: SessionLock.authenticating && !SessionLock.responseRequired
	readonly property int sidePadding: root.width < 900 ? 24 : 40
	readonly property int topPadding: root.height < 760 ? 28 : 44
	readonly property int bottomPadding: root.height < 760 ? 24 : 36
	readonly property bool compactLayout: root.width < 840

	anchors.fill: parent
	color: "#0a0d13"

	gradient: Gradient {
		GradientStop {
			position: 0.0
			color: "#0c1017"
		}
		GradientStop {
			position: 0.52
			color: "#121722"
		}
		GradientStop {
			position: 1.0
			color: "#090b10"
		}
	}

	Rectangle {
		anchors.fill: parent
		gradient: Gradient {
			GradientStop {
				position: 0.0
				color: "#00000000"
			}
			GradientStop {
				position: 1.0
				color: "#a0000000"
			}
		}
	}

	Rectangle {
		width: Math.max(420, parent.width * 0.42)
		height: width
		radius: width / 2
		color: "#16ffffff"
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: -height * 0.6
	}

	Rectangle {
		width: Math.max(280, parent.width * 0.24)
		height: width
		radius: width / 2
		color: "#14" + Theme.active.toString().slice(1)
		anchors.left: parent.left
		anchors.leftMargin: -width * 0.25
		anchors.bottom: parent.bottom
		anchors.bottomMargin: -height * 0.35
	}

	Rectangle {
		width: Math.max(180, parent.width * 0.16)
		height: width
		radius: width / 2
		color: "#10b8d8ba"
		anchors.right: parent.right
		anchors.rightMargin: -width * 0.22
		anchors.top: parent.top
		anchors.topMargin: parent.height * 0.22
	}

	Item {
		anchors.fill: parent
		focus: true

		Keys.onEscapePressed: event => event.accepted = true

		ColumnLayout {
			anchors.fill: parent
			anchors.leftMargin: root.sidePadding
			anchors.rightMargin: root.sidePadding
			anchors.topMargin: root.topPadding
			anchors.bottomMargin: root.bottomPadding
			spacing: 18

			RowLayout {
				Layout.fillWidth: true
				spacing: 16

				MText {
					text: "LOCKED"
					font.pointSize: 11
					font.letterSpacing: 2
					color: Theme.active
				}

				Item {
					Layout.fillWidth: true
				}

				Rectangle {
					radius: height / 2
					color: SessionLock.secure ? "#1e3a2b" : "#232836"
					border.width: 1
					border.color: SessionLock.secure ? "#2f7f53" : "#384155"
					implicitHeight: statusLabel.implicitHeight + 12
					implicitWidth: statusLabel.implicitWidth + 18

					MText {
						id: statusLabel
						anchors.centerIn: parent
						text: SessionLock.secure ? "Secure" : "Securing displays"
						font.pointSize: 10
						color: SessionLock.secure ? Theme.accept : Theme.inactive
					}
				}
			}

			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true

				ColumnLayout {
					anchors.centerIn: parent
					width: Math.min(parent.width, root.compactLayout ? 520 : 760)
					spacing: root.compactLayout ? 16 : 22

					ColumnLayout {
						Layout.alignment: Qt.AlignHCenter
						spacing: 2

						MText {
							Layout.alignment: Qt.AlignHCenter
							text: Time.format("HH:mm")
							font.family: Theme.font
							font.pointSize: root.compactLayout ? 74 : 108
							color: Theme.text
						}

						MText {
							Layout.alignment: Qt.AlignHCenter
							text: Time.format("dddd, MMMM d")
							font.pointSize: root.compactLayout ? 16 : 18
							color: "#aab4c8"
						}
					}

					SurfaceCard {
						Layout.alignment: Qt.AlignHCenter
						Layout.fillWidth: true
						Layout.maximumWidth: root.compactLayout ? 520 : 620
						cardColor: "#cc131925"
						cardBorderWidth: 1
						cardBorderColor: SessionLock.statusError ? Theme.deny : "#334155"
						padding: root.compactLayout ? 22 : 28
						contentSpacing: root.compactLayout ? 14 : 18

						ColumnLayout {
							spacing: 6

							MText {
								text: "Welcome back"
								font.pointSize: 14
								color: Theme.active
							}

							MText {
								text: SessionLock.prompt.length > 0 ? SessionLock.prompt : "Enter your password to unlock your session."
								font.pointSize: 13
								color: SessionLock.messageIsError ? Theme.deny : Theme.text
								wrapMode: Text.Wrap
							}
						}

						Rectangle {
							Layout.alignment: Qt.AlignLeft
							radius: height / 2
							color: "#2c1520"
							border.width: 1
							border.color: "#7a2b3e"
							visible: InputContext.capsLockActive
							implicitHeight: capsLabel.implicitHeight + 12
							implicitWidth: capsRow.implicitWidth + 18

							RowLayout {
								id: capsRow
								anchors.centerIn: parent
								spacing: 8

								MaterialIcon {
									text: "keyboard_capslock"
									font.pointSize: 18
									color: Theme.deny
								}

								MText {
									id: capsLabel
									text: "Caps Lock is on"
									font.pointSize: 10
									color: Theme.deny
								}
							}
						}

						Rectangle {
							Layout.fillWidth: true
							implicitHeight: root.compactLayout ? 56 : 60
							radius: 18
							color: "#0d1118"
							border.width: 1
							border.color: passwordField.activeFocus ? Theme.active : "#273244"

							RowLayout {
								anchors.fill: parent
								anchors.leftMargin: 16
								anchors.rightMargin: 16
								spacing: 12

								MaterialIcon {
									text: "lock"
									font.pointSize: 22
									color: passwordField.activeFocus ? Theme.active : Theme.inactive
								}

								MTextField {
									id: passwordField
									Layout.fillWidth: true
									verticalAlignment: Text.AlignVCenter
									focus: SessionLock.locked
									selectByMouse: true
									echoMode: SessionLock.responseVisible ? TextInput.Normal : TextInput.Password
									enabled: !root.busyAuthenticating
									color: Theme.text
									placeholderText: root.busyAuthenticating ? "Authenticating..." : (SessionLock.responseVisible ? "Response" : "Password")
									placeholderTextColor: "#6b7280"
									font.family: Theme.font
									font.pointSize: 12
									background: null
					onTextChanged: {
						if (text !== SessionLock.response) {
							SessionLock.response = text;
							if (SessionLock.statusError)
								SessionLock.statusText = "";
						}
					}
									onAccepted: SessionLock.submit()
									Component.onCompleted: {
										text = SessionLock.response;
										forceActiveFocus();
									}
								}

								PillButton {
									text: "Unlock"
									disabled: root.busyAuthenticating || SessionLock.response.length === 0
									active: !disabled
									onClick: SessionLock.submit()
								}

								BusyIndicator {
									running: root.busyAuthenticating
									visible: running
									implicitWidth: 18
									implicitHeight: 18
								}
							}

							Connections {
								target: SessionLock

								function onResponseChanged(): void {
									if (passwordField.text !== SessionLock.response)
										passwordField.text = SessionLock.response;
								}
							}
						}

						Rectangle {
							Layout.fillWidth: true
							radius: 14
							color: SessionLock.statusError ? "#2c151b" : "#151b26"
							border.width: 1
							border.color: SessionLock.statusError ? "#6b2231" : "#222b3b"
							visible: statusText.text.length > 0
							implicitHeight: statusText.implicitHeight + 20

							MText {
								id: statusText
								anchors.fill: parent
								anchors.margins: 10
								text: SessionLock.statusText
								font.pointSize: 10
								color: SessionLock.statusError ? Theme.deny : Theme.inactive
								wrapMode: Text.Wrap
							}
						}

						MText {
							text: "Press Enter to submit"
							font.pointSize: 10
							color: Theme.inactive
						}
					}
				}
			}

			Flow {
				Layout.fillWidth: true
				spacing: 12

				Rectangle {
					radius: 18
					color: "#b8141923"
					border.width: 1
					border.color: "#263245"
					implicitWidth: weatherRow.implicitWidth + 28
					implicitHeight: weatherRow.implicitHeight + 20

					RowLayout {
						id: weatherRow
						anchors.centerIn: parent
						spacing: 10

						MaterialIcon {
							text: Weather.currentIcon
							font.pointSize: 22
							color: Theme.text
						}

						ColumnLayout {
							spacing: 0

							MText {
								text: Weather.currentTemp ? `${Weather.currentTemp}°` : "--"
								font.pointSize: 14
							}

							MText {
								text: Weather.error.length > 0 ? "Weather unavailable" : (Weather.currentCondition && Weather.currentCondition.weatherDesc && Weather.currentCondition.weatherDesc.length > 0 ? Weather.currentCondition.weatherDesc[0].value : "Weather")
								font.pointSize: 10
								color: Weather.error.length > 0 ? Theme.deny : Theme.inactive
							}
						}
					}
				}

				Rectangle {
					radius: 18
					color: "#b8141923"
					border.width: 1
					border.color: "#263245"
					implicitWidth: metricsRow.implicitWidth + 28
					implicitHeight: metricsRow.implicitHeight + 20

					RowLayout {
						id: metricsRow
						anchors.centerIn: parent
						spacing: 18

						ColumnLayout {
							spacing: 1

							MText {
								text: "CPU"
								font.pointSize: 9
								color: Theme.inactive
							}

							MText {
								text: SystemMetrics.cpuLabel
								font.pointSize: 12
							}
						}

						ColumnLayout {
							spacing: 1

							MText {
								text: "MEM"
								font.pointSize: 9
								color: Theme.inactive
							}

							MText {
								text: SystemMetrics.memoryLabel
								font.pointSize: 12
							}
						}

						ColumnLayout {
							spacing: 1

							MText {
								text: "DISK"
								font.pointSize: 9
								color: Theme.inactive
							}

							MText {
								text: SystemMetrics.diskLabel
								font.pointSize: 12
							}
						}
					}
				}

				Rectangle {
					radius: 18
					color: "#b8141923"
					border.width: 1
					border.color: "#263245"
					implicitWidth: batteryWidget.implicitWidth + 28
					implicitHeight: batteryWidget.implicitHeight + 20

					BatteryWidget {
						id: batteryWidget
						anchors.centerIn: parent
						showLabel: true
						iconPointSize: 22
						textPointSize: 12
					}
				}
			}
		}
	}
}
