pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.widgets
import qs.services
import qs.config
import QtQuick.Window

Window {
	id: root
	readonly property string panelName: "monitorProfiles"
	title: "Monitor Profiles"
	width: 960
	height: 780
	minimumWidth: 780
	minimumHeight: 620
	color: "transparent"
	visibility: Window.AutomaticVisibility
	flags: Qt.Window
	property string selectedMonitorName: ""
	readonly property real previewPadding: 24
	readonly property int snapThreshold: 64
	readonly property int workspaceMinX: -3840
	readonly property int workspaceMaxX: 3840
	readonly property int workspaceMinY: -2160
	readonly property int workspaceMaxY: 2160
	readonly property int workspaceWidth: workspaceMaxX - workspaceMinX
	readonly property int workspaceHeight: workspaceMaxY - workspaceMinY
	readonly property var selectedMonitor: root.monitorByName(root.selectedMonitorName)

	visible: Visibilities.is(root.panelName)
	onVisibleChanged: {
		if (visible)
			root.requestActivate();
	}
	onClosing: close => {
		close.accepted = false;
		Visibilities.set(root.panelName, false);
	}

	function monitorByName(name: string): var {
		const drafts = MonitorProfiles.monitorDrafts || [];
		for (let i = 0; i < drafts.length; i++) {
			if (drafts[i].name === name)
				return drafts[i];
		}
		return null;
	}

	function ensureSelection(): void {
		if (root.monitorByName(root.selectedMonitorName))
			return;
		root.selectedMonitorName = MonitorProfiles.monitorDrafts.length > 0 ? MonitorProfiles.monitorDrafts[0].name : "";
	}

	function previewScale(canvasWidth: real, canvasHeight: real): real {
		const usableWidth = Math.max(1, canvasWidth - (root.previewPadding * 2));
		const usableHeight = Math.max(1, canvasHeight - (root.previewPadding * 2));
		return Math.min(usableWidth / root.workspaceWidth, usableHeight / root.workspaceHeight);
	}

	function clamp(value: real, minValue: real, maxValue: real): real {
		return Math.max(minValue, Math.min(maxValue, value));
	}

	function rectsOverlap(a: var, b: var): bool {
		return a.x < (b.x + b.width) && (a.x + a.width) > b.x && a.y < (b.y + b.height) && (a.y + a.height) > b.y;
	}

	function monitorRectFor(name: string, x: real, y: real): var {
		const drafts = MonitorProfiles.monitorDrafts || [];
		const current = root.monitorByName(name);
		if (!current)
			return {
				x: Math.round(x),
				y: Math.round(y),
				width: 320,
				height: 180
			};

		const width = Math.max(current.width, 320);
		const height = Math.max(current.height, 180);
		return {
			x: Math.round(root.clamp(x, root.workspaceMinX, root.workspaceMaxX - width)),
			y: Math.round(root.clamp(y, root.workspaceMinY, root.workspaceMaxY - height)),
			width: width,
			height: height
		};
	}

	function overlapsAnyOther(name: string, x: real, y: real): bool {
		const drafts = MonitorProfiles.monitorDrafts || [];
		const moving = root.monitorRectFor(name, x, y);
		for (let i = 0; i < drafts.length; i++) {
			const draft = drafts[i];
			if (draft.name === name)
				continue;
			const other = {
				x: draft.x,
				y: draft.y,
				width: Math.max(draft.width, 320),
				height: Math.max(draft.height, 180)
			};
			if (root.rectsOverlap(moving, other))
				return true;
		}
		return false;
	}

	function rangesIntersect(startA: real, endA: real, startB: real, endB: real, gap: real): bool {
		return Math.min(endA, endB) >= (Math.max(startA, startB) - gap);
	}

	function snappedMonitorRect(name: string, x: real, y: real): var {
		const snapped = root.monitorRectFor(name, x, y);
		const drafts = MonitorProfiles.monitorDrafts || [];
		let bestX = snapped.x;
		let bestY = snapped.y;
		let bestXDistance = root.snapThreshold + 1;
		let bestYDistance = root.snapThreshold + 1;

		for (let i = 0; i < drafts.length; i++) {
			const draft = drafts[i];
			if (draft.name === name)
				continue;

			const other = {
				x: draft.x,
				y: draft.y,
				width: Math.max(draft.width, 320),
				height: Math.max(draft.height, 180)
			};

			const verticalAligned = root.rangesIntersect(snapped.y, snapped.y + snapped.height, other.y, other.y + other.height, root.snapThreshold);
			if (verticalAligned) {
				const xCandidates = [other.x - snapped.width, other.x + other.width];
				for (let j = 0; j < xCandidates.length; j++) {
					const candidateX = xCandidates[j];
					const distanceX = Math.abs(candidateX - snapped.x);
					if (distanceX < bestXDistance && !root.overlapsAnyOther(name, candidateX, bestY)) {
						bestXDistance = distanceX;
						bestX = candidateX;
					}
				}
			}

			const horizontalAligned = root.rangesIntersect(snapped.x, snapped.x + snapped.width, other.x, other.x + other.width, root.snapThreshold);
			if (horizontalAligned) {
				const yCandidates = [other.y - snapped.height, other.y + other.height];
				for (let j = 0; j < yCandidates.length; j++) {
					const candidateY = yCandidates[j];
					const distanceY = Math.abs(candidateY - snapped.y);
					if (distanceY < bestYDistance && !root.overlapsAnyOther(name, bestX, candidateY)) {
						bestYDistance = distanceY;
						bestY = candidateY;
					}
				}
			}
		}

		return root.monitorRectFor(name, bestX, bestY);
	}

	Connections {
		target: MonitorProfiles
		function onMonitorDraftsChanged() {
			root.ensureSelection();
		}
	}

	SurfaceCard {
		anchors.fill: parent
		cardColor: Theme.background
		cardBorderWidth: 1
		cardBorderColor: Theme.hover
		padding: 16
		contentSpacing: 14
		opacity: root.visible ? 1 : 0
		scale: root.visible ? 1 : 0.985

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.motionBase
				easing.type: Easing.OutCubic
			}
		}

		Behavior on scale {
			NumberAnimation {
				duration: Theme.motionBase
				easing.type: Easing.OutCubic
			}
		}

		ColumnLayout {
			anchors.fill: parent
			spacing: 12

			RowLayout {
				Layout.fillWidth: true

				ColumnLayout {
					spacing: 2

					MText {
						text: "Monitor Profiles"
						font.pointSize: 14
					}

					MText {
						text: "Save monitor layouts to JSON and generate Hyprland monitor rules."
						font.pointSize: 10
						color: Theme.inactive
					}
				}

				Item {
					Layout.fillWidth: true
				}

				IconButton {
					diameter: 30
					icon: "close"
					iconPointSize: 14
					onClick: Visibilities.set(root.panelName, false)
				}
			}

			SurfaceCard {
				cardColor: Theme.foreground
				padding: 12
				contentSpacing: 10

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 10

					RowLayout {
						Layout.fillWidth: true
						spacing: 10

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 4

							MText {
								text: "Profile name"
								font.pointSize: 10
								color: Theme.inactive
							}

							TextField {
								text: MonitorProfiles.profileName
								enabled: !MonitorProfiles.busy
								Layout.fillWidth: true
								selectByMouse: true
								onTextEdited: MonitorProfiles.profileName = text
							}
						}

						PillButton {
							text: "New Profile"
							baseColor: Theme.foreground2
							disabled: MonitorProfiles.busy
							onClick: MonitorProfiles.createProfile()
						}

						PillButton {
							text: "Reload Monitors"
							baseColor: Theme.foreground2
							disabled: MonitorProfiles.busy
							onClick: MonitorProfiles.resetDraftsFromSystem()
						}

						PillButton {
							text: "Save JSON"
							baseColor: Theme.foreground2
							disabled: MonitorProfiles.busy || MonitorProfiles.profileName.trim().length === 0
							onClick: MonitorProfiles.saveProfile()
						}

						PillButton {
							text: "Apply"
							active: true
							disabled: MonitorProfiles.busy || MonitorProfiles.monitorDrafts.length === 0
							onClick: MonitorProfiles.applyProfile()
						}
					}

					MText {
						text: MonitorProfiles.loadedProfileName.length > 0 ? `Loaded profile: ${MonitorProfiles.loadedProfileName}` : "Loaded profile: live Hyprland state"
						font.pointSize: 10
						color: Theme.inactive
					}

					MText {
						text: MonitorProfiles.statusMessage
						font.pointSize: 10
						color: Theme.accept
						visible: MonitorProfiles.statusMessage.length > 0
					}

					MText {
						text: MonitorProfiles.errorMessage
						font.pointSize: 10
						color: Theme.deny
						wrapMode: Text.Wrap
						visible: MonitorProfiles.errorMessage.length > 0
					}
				}
			}

			SurfaceCard {
				cardColor: Theme.foreground
				padding: 12
				contentSpacing: 10

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 10

					RowLayout {
						Layout.fillWidth: true

						MText {
							text: "Saved Profiles"
							font.pointSize: 12
						}

						Item {
							Layout.fillWidth: true
						}

						IconButton {
							diameter: 28
							icon: "refresh"
							iconPointSize: 14
							onClick: MonitorProfiles.refreshSavedProfiles()
						}
					}

					ListView {
						id: profilesList
						Layout.fillWidth: true
						Layout.preferredHeight: 156
						clip: true
						spacing: 8
						model: MonitorProfiles.savedProfiles
						boundsBehavior: Flickable.StopAtBounds

						ScrollBar.vertical: ScrollBar {
							policy: profilesList.contentHeight > profilesList.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
						}

						delegate: Item {
							required property string modelData
							width: profilesList.width
							height: 58

							SurfaceCard {
								anchors.fill: parent
								cardColor: MonitorProfiles.loadedProfileName === modelData ? Theme.active : Theme.foreground2
								cardBorderWidth: MonitorProfiles.loadedProfileName === modelData ? 1 : 0
								cardBorderColor: MonitorProfiles.loadedProfileName === modelData ? Theme.text : "transparent"
								padding: 10
								contentSpacing: 0

								RowLayout {
									Layout.fillWidth: true
									spacing: 10

									ColumnLayout {
										Layout.fillWidth: true
										spacing: 2

										MText {
											Layout.fillWidth: true
											text: modelData.replace(/\.json$/, "")
											font.pointSize: 11
											elide: Text.ElideRight
											color: MonitorProfiles.loadedProfileName === modelData ? Theme.background : Theme.text
										}

										MText {
											Layout.fillWidth: true
											text: MonitorProfiles.loadedProfileName === modelData ? "Loaded now" : modelData
											font.pointSize: 9
											elide: Text.ElideRight
											color: MonitorProfiles.loadedProfileName === modelData ? Theme.background : Theme.inactive
										}
									}

									PillButton {
										text: "Load"
										baseColor: Theme.foreground
										disabled: MonitorProfiles.busy || MonitorProfiles.loadedProfileName === modelData
										onClick: MonitorProfiles.loadProfile(modelData)
									}

									PillButton {
										text: "Delete"
										baseColor: Theme.foreground
										disabled: MonitorProfiles.busy
										onClick: MonitorProfiles.deleteProfile(modelData)
									}
								}
							}
						}

						footer: Item {
							width: profilesList.width
							height: MonitorProfiles.savedProfiles.length === 0 ? 64 : 0
							visible: MonitorProfiles.savedProfiles.length === 0

							SurfaceCard {
								anchors.fill: parent
								cardColor: Theme.foreground2
								padding: 10
								contentSpacing: 6

								ColumnLayout {
									spacing: 6

									MText {
										text: "No saved profiles yet."
										font.pointSize: 10
									}

									MText {
										text: "Create one, then save it here."
										font.pointSize: 10
										color: Theme.inactive
									}
								}
							}
						}
					}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 12

				SurfaceCard {
					Layout.fillWidth: true
					Layout.minimumWidth: 420
					Layout.fillHeight: true
					cardColor: Theme.foreground
					padding: 12
					contentSpacing: 10

					ColumnLayout {
						Layout.fillWidth: true
						Layout.fillHeight: true
						spacing: 10

						RowLayout {
							Layout.fillWidth: true
							MText {
								text: "Layout Editor"
								font.pointSize: 12
							}

							Item {
								Layout.fillWidth: true
							}

							MText {
								text: "Drag displays to update X/Y"
								font.pointSize: 10
								color: Theme.inactive
							}
						}

						RowLayout {
							Layout.fillWidth: true
							Layout.fillHeight: true
							spacing: 12

							Rectangle {
								id: previewFrame
								Layout.fillWidth: true
								Layout.fillHeight: true
								radius: Theme.rounded
								color: Theme.foreground2
								border.width: 1
								border.color: Theme.hover

								Item {
									id: previewCanvas
									anchors.fill: parent
									anchors.margins: 14
									property real scaleFactor: root.previewScale(width, height)
									property real offsetX: (width - (root.workspaceWidth * scaleFactor)) / 2
									property real offsetY: (height - (root.workspaceHeight * scaleFactor)) / 2

									Rectangle {
										x: previewCanvas.offsetX
										y: previewCanvas.offsetY
										width: root.workspaceWidth * previewCanvas.scaleFactor
										height: root.workspaceHeight * previewCanvas.scaleFactor
										radius: Theme.rounded
										color: "transparent"
										border.width: 1
										border.color: Theme.hover
									}

									Rectangle {
										x: previewCanvas.offsetX + ((0 - root.workspaceMinX) * previewCanvas.scaleFactor)
										y: previewCanvas.offsetY
										width: 1
										height: root.workspaceHeight * previewCanvas.scaleFactor
										color: Theme.hover
										opacity: 0.5
									}

									Rectangle {
										x: previewCanvas.offsetX
										y: previewCanvas.offsetY + ((0 - root.workspaceMinY) * previewCanvas.scaleFactor)
										width: root.workspaceWidth * previewCanvas.scaleFactor
										height: 1
										color: Theme.hover
										opacity: 0.5
									}

									Repeater {
										model: MonitorProfiles.monitorDrafts

										delegate: Rectangle {
											id: monitorCard
											required property var modelData
											property real dragStartCanvasX: 0
											property real dragStartCanvasY: 0
											property real startMonitorX: 0
											property real startMonitorY: 0
											property real previewWidth: Math.max(72, (modelData.width > 0 ? modelData.width : 320) * previewCanvas.scaleFactor)
											property real previewHeight: Math.max(48, (modelData.height > 0 ? modelData.height : 180) * previewCanvas.scaleFactor)
											property real previewX: previewCanvas.offsetX + ((modelData.x - root.workspaceMinX) * previewCanvas.scaleFactor)
											property real previewY: previewCanvas.offsetY + ((modelData.y - root.workspaceMinY) * previewCanvas.scaleFactor)

											function syncGeometry(): void {
												if (dragArea.pressed)
													return;
												x = previewX;
												y = previewY;
												width = previewWidth;
												height = previewHeight;
											}

											Component.onCompleted: {
												root.ensureSelection();
												syncGeometry();
											}
											onPreviewXChanged: syncGeometry()
											onPreviewYChanged: syncGeometry()
											onPreviewWidthChanged: syncGeometry()
											onPreviewHeightChanged: syncGeometry()

											radius: Theme.rounded
											color: modelData.enabled === false ? Theme.inactive : (root.selectedMonitorName === modelData.name ? Theme.active : Theme.background)
											border.width: root.selectedMonitorName === modelData.name ? 2 : 1
											border.color: root.selectedMonitorName === modelData.name ? Theme.text : Theme.hover
											opacity: modelData.enabled === false ? 0.45 : 0.92
											scale: dragArea.pressed ? 1.03 : 1

											Behavior on x {
												NumberAnimation {
													duration: dragArea.pressed ? 0 : Theme.motionFast
													easing.type: Easing.OutCubic
												}
											}

											Behavior on y {
												NumberAnimation {
													duration: dragArea.pressed ? 0 : Theme.motionFast
													easing.type: Easing.OutCubic
												}
											}

											Behavior on color {
												ColorAnimation {
													duration: Theme.motionFast
												}
											}

											Behavior on scale {
												NumberAnimation {
													duration: Theme.motionFast
													easing.type: Easing.OutCubic
												}
											}

											Column {
												anchors.centerIn: parent
												width: parent.width - 16
												spacing: 2

												MText {
													width: parent.width
													text: modelData.name
													font.pointSize: 10
													horizontalAlignment: Text.AlignHCenter
													elide: Text.ElideRight
												}

												MText {
													width: parent.width
													text: `${modelData.width}x${modelData.height}`
													font.pointSize: 9
													color: root.selectedMonitorName === modelData.name ? Theme.background : Theme.inactive
													horizontalAlignment: Text.AlignHCenter
													elide: Text.ElideRight
												}
											}

											MouseArea {
												id: dragArea
												anchors.fill: parent
												preventStealing: true
												cursorShape: Qt.OpenHandCursor
												onPressed: {
													root.selectedMonitorName = modelData.name;
													const startPoint = monitorCard.mapToItem(previewCanvas, mouse.x, mouse.y);
													monitorCard.dragStartCanvasX = startPoint.x;
													monitorCard.dragStartCanvasY = startPoint.y;
													monitorCard.startMonitorX = modelData.x;
													monitorCard.startMonitorY = modelData.y;
													cursorShape = Qt.ClosedHandCursor;
												}
												onPositionChanged: mouse => {
													if (!pressed)
														return;
													const currentPoint = monitorCard.mapToItem(previewCanvas, mouse.x, mouse.y);
													const deltaX = currentPoint.x - monitorCard.dragStartCanvasX;
													const deltaY = currentPoint.y - monitorCard.dragStartCanvasY;
													const targetX = root.workspaceMinX + ((((previewCanvas.offsetX + ((monitorCard.startMonitorX - root.workspaceMinX) * previewCanvas.scaleFactor) + deltaX) - previewCanvas.offsetX) / previewCanvas.scaleFactor));
													const targetY = root.workspaceMinY + ((((previewCanvas.offsetY + ((monitorCard.startMonitorY - root.workspaceMinY) * previewCanvas.scaleFactor) + deltaY) - previewCanvas.offsetY) / previewCanvas.scaleFactor));
													const snapped = root.snappedMonitorRect(modelData.name, targetX, targetY);
													monitorCard.x = previewCanvas.offsetX + ((snapped.x - root.workspaceMinX) * previewCanvas.scaleFactor);
													monitorCard.y = previewCanvas.offsetY + ((snapped.y - root.workspaceMinY) * previewCanvas.scaleFactor);
												}
												onReleased: {
													cursorShape = Qt.OpenHandCursor;
													const targetX = root.workspaceMinX + ((monitorCard.x - previewCanvas.offsetX) / previewCanvas.scaleFactor);
													const targetY = root.workspaceMinY + ((monitorCard.y - previewCanvas.offsetY) / previewCanvas.scaleFactor);
													const clamped = root.snappedMonitorRect(modelData.name, targetX, targetY);
													if (root.overlapsAnyOther(modelData.name, clamped.x, clamped.y)) {
														MonitorProfiles.statusMessage = "";
														MonitorProfiles.errorMessage = "Monitor positions cannot overlap.";
														monitorCard.syncGeometry();
														return;
													}
													MonitorProfiles.errorMessage = "";
													MonitorProfiles.setDraftFields(modelData.name, {
														x: clamped.x,
														y: clamped.y
													});
												}
												onClicked: root.selectedMonitorName = modelData.name
											}
										}
									}

									MText {
										anchors.centerIn: parent
										text: MonitorProfiles.monitorDrafts.length === 0 ? "No monitors available." : ""
										font.pointSize: 11
										color: Theme.inactive
										visible: MonitorProfiles.monitorDrafts.length === 0
									}
								}
							}

							SurfaceCard {
								Layout.preferredWidth: 300
								Layout.minimumWidth: 300
								Layout.maximumWidth: 320
								Layout.fillWidth: false
								Layout.fillHeight: true
								cardColor: Theme.foreground2
								padding: 12
								contentSpacing: 10

								ColumnLayout {
									Layout.fillWidth: true
									Layout.fillHeight: true
									spacing: 10

									MText {
										text: "Inspector"
										font.pointSize: 12
									}

									Flickable {
										id: inspectorViewport
										Layout.fillWidth: true
										Layout.fillHeight: true
										contentWidth: width
										contentHeight: inspectorContent.implicitHeight
										boundsBehavior: Flickable.StopAtBounds
										clip: true

										ScrollBar.vertical: ScrollBar {
											policy: inspectorViewport.contentHeight > inspectorViewport.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
										}

										ColumnLayout {
											id: inspectorContent
											width: inspectorViewport.width
											spacing: 10

											MText {
												Layout.fillWidth: true
												text: root.selectedMonitor ? root.selectedMonitor.name : "Select a monitor"
												font.pointSize: 11
												color: root.selectedMonitor ? Theme.text : Theme.inactive
											}

											MText {
												Layout.fillWidth: true
												text: root.selectedMonitor ? root.selectedMonitor.description : "Click a display in the layout to edit its properties."
												font.pointSize: 10
												color: Theme.inactive
												wrapMode: Text.Wrap
											}

											CheckBox {
												enabled: !MonitorProfiles.busy && !!root.selectedMonitor
												checked: root.selectedMonitor ? root.selectedMonitor.enabled : false
												text: "Enabled"
												onToggled: {
													if (root.selectedMonitor)
														MonitorProfiles.setDraftField(root.selectedMonitor.name, "enabled", checked);
												}
											}

											GridLayout {
												Layout.fillWidth: true
												columns: 2
												columnSpacing: 10
												rowSpacing: 8
												enabled: !!root.selectedMonitor

												MText {
													text: "Width"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.width}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "width", text);
													}
												}

												MText {
													text: "Height"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.height}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "height", text);
													}
												}

												MText {
													text: "Refresh"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.refreshRate}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "refreshRate", text);
													}
												}

												MText {
													text: "Scale"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.scale}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "scale", text);
													}
												}

												MText {
													text: "X"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.x}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "x", text);
													}
												}

												MText {
													text: "Y"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.y}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "y", text);
													}
												}

												MText {
													text: "Transform"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? `${root.selectedMonitor.transform}` : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "transform", text);
													}
												}

												MText {
													text: "Mirror"
													color: Theme.inactive
													font.pointSize: 10
												}
												TextField {
													text: root.selectedMonitor ? root.selectedMonitor.mirror : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													selectByMouse: true
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "mirror", text);
													}
												}
											}

											ColumnLayout {
												Layout.fillWidth: true
												spacing: 4

												MText {
													text: "Extra args"
													color: Theme.inactive
													font.pointSize: 10
												}

												TextField {
													text: root.selectedMonitor ? root.selectedMonitor.extraArgs : ""
													enabled: !MonitorProfiles.busy && !!root.selectedMonitor
													Layout.fillWidth: true
													selectByMouse: true
													placeholderText: "Example: bitdepth, 10"
													onEditingFinished: {
														if (root.selectedMonitor)
															MonitorProfiles.setDraftField(root.selectedMonitor.name, "extraArgs", text);
													}
												}
											}

											MText {
												Layout.fillWidth: true
												wrapMode: Text.Wrap
												font.pointSize: 10
												color: Theme.inactive
												text: root.selectedMonitor ? MonitorProfiles.buildMonitorLine(root.selectedMonitor) : "Select a monitor to preview its Hyprland rule."
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	Component.onCompleted: {
		Visibilities.addPanel(root.panelName);
		root.ensureSelection();
	}
}
