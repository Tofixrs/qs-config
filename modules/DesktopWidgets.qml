import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.widgets
import qs.services
import qs.modules.todo

Item {
	id: root

	anchors.fill: parent

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
			property bool forecastExpanded: false

			ColumnLayout {
				spacing: 10

				RowLayout {
					spacing: 10

					MaterialIcon {
						id: weatherIcon
						text: Weather.currentIcon
						smooth: true
					}

					ColumnLayout {
						MText {
							text: Weather.currentTemp ? Weather.currentTemp + "°" : "--"
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
						diameter: 40
						icon: weatherContainer.forecastExpanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
						iconPointSize: 26
						onClick: weatherContainer.forecastExpanded = !weatherContainer.forecastExpanded
					}

					IconButton {
						diameter: 48
						icon: "refresh"
						iconPointSize: 32
						onClick: Weather.refreshCurrent()
					}
				}

				MText {
					text: Weather.error.length > 0 ? "Unable to load weather (" + Weather.error + ")" : ""
					font.pointSize: 10
					color: Theme.deny
					visible: Weather.error.length > 0
				}

				ColumnLayout {
					visible: weatherContainer.forecastExpanded
					spacing: 6

					Rectangle {
						Layout.fillWidth: true
						height: 1
						color: Theme.hover
					}

					Repeater {
						model: Weather.dailyForecast.slice(0, 3)

						delegate: RowLayout {
							required property var modelData
							Layout.fillWidth: true
							spacing: 10

							MaterialIcon {
								text: Icons.weatherIcons[modelData.hourly && modelData.hourly.length > 0 ? modelData.hourly[0].weatherCode : 113]
								font.pointSize: 20
								color: Theme.text
							}

							ColumnLayout {
								spacing: 1

								MText {
									text: modelData.date ? Qt.formatDate(new Date(modelData.date), "ddd") : ""
									font.pointSize: 10
								}

								MText {
									text: modelData.hourly && modelData.hourly.length > 0 && modelData.hourly[0].weatherDesc && modelData.hourly[0].weatherDesc.length > 0 ? modelData.hourly[0].weatherDesc[0].value : ""
									font.pointSize: 9
									color: Theme.inactive
								}
							}

							Item {
								Layout.fillWidth: true
							}

							MText {
								text: (modelData.mintempC || "--") + "° / " + (modelData.maxtempC || "--") + "°"
								font.pointSize: 10
								color: Theme.text
							}
						}
					}
				}
			}
		}
	}

	SurfaceCard {
		id: todoCard
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.topMargin: 56
		anchors.rightMargin: 28
		width: 380
		padding: 14
		contentSpacing: 12
		cardColor: Theme.foreground
		cardBorderWidth: 1
		cardBorderColor: Theme.hover

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 12

			RowLayout {
				Layout.fillWidth: true

				ColumnLayout {
					spacing: 2

					MText {
						text: "To do"
						font.pointSize: 14
					}

					MText {
						text: TodoService.totalTasks === 0 ? "No tasks yet" : TodoService.completedTasks + "/" + TodoService.totalTasks + " complete"
						font.pointSize: 10
						color: Theme.inactive
					}
				}

				Item {
					Layout.fillWidth: true
				}

				IconButton {
					diameter: 32
					icon: "add_task"
					iconPointSize: 18
					iconColor: Theme.active
					onClick: {
						TodoService.addTask(newTodoField.text);
						newTodoField.text = "";
					}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				MTextField {
					id: newTodoField
					Layout.fillWidth: true
					placeholderText: "Add a task"
					selectByMouse: true
					onAccepted: {
						TodoService.addTask(text);
						text = "";
					}
				}

				PillButton {
					text: "Add"
					disabled: newTodoField.text.trim().length === 0
					onClick: {
						TodoService.addTask(newTodoField.text);
						newTodoField.text = "";
					}
				}
			}

			MText {
				text: TodoService.errorMessage
				font.pointSize: 10
				color: Theme.deny
				wrapMode: Text.Wrap
				visible: TodoService.errorMessage.length > 0
			}

			Flickable {
				Layout.fillWidth: true
				Layout.preferredHeight: 420
				contentWidth: width
				contentHeight: todoColumn.implicitHeight
				boundsBehavior: Flickable.StopAtBounds
				clip: true

				Column {
					id: todoColumn
					width: todoCard.width - (todoCard.padding * 2)
					spacing: 8

					TodoTree {
						width: todoColumn.width
						tasks: TodoService.tasks
					}

					Rectangle {
						width: parent.width
						height: 72
						radius: Theme.rounded
						color: Theme.foreground2
						border.width: 1
						border.color: Theme.hover
						visible: TodoService.tasks.length === 0

						MText {
							anchors.centerIn: parent
							text: "Add a task, then attach subtasks to break it down."
							font.pointSize: 10
							color: Theme.inactive
							wrapMode: Text.Wrap
							width: parent.width - 24
							horizontalAlignment: Text.AlignHCenter
						}
					}
				}
			}
		}
	}

	SurfaceCard {
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.leftMargin: 28
		anchors.bottomMargin: 36
		padding: 14
		contentSpacing: 10
		cardColor: Theme.foreground
		cardBorderWidth: 1
		cardBorderColor: Theme.hover

		ColumnLayout {
			spacing: 10

			RowLayout {
				Layout.fillWidth: true

				ColumnLayout {
					spacing: 2

					MText {
						text: "System"
						font.pointSize: 14
					}

					MText {
						text: "Live resource usage"
						font.pointSize: 10
						color: Theme.inactive
					}
				}
			}

			RowLayout {
				spacing: 14

				RingMeter {
					progress: SystemMetrics.cpuUsage
					progressColor: Theme.active
					icon: "memory"
					valueText: SystemMetrics.cpuLabel
					label: "CPU"
				}

				RingMeter {
					progress: SystemMetrics.memoryUsage
					progressColor: Theme.accept
					icon: "developer_board"
					valueText: SystemMetrics.memoryLabel
					label: "RAM"
				}

				RingMeter {
					progress: SystemMetrics.diskUsage
					progressColor: Theme.deny
					icon: "hard_disk"
					valueText: SystemMetrics.diskLabel
					label: "Disk"
				}
			}
		}
	}
}
