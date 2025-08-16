pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.widgets
import qs.services as S
import "./modules"

Variants {
	id: root
	model: Quickshell.screens
	StyledWindow {
		id: win
		required property ShellScreen modelData
		screen: modelData
		name: "dashboard"
		anchors.bottom: true
		implicitWidth: child.width
		implicitHeight: child.height
		WlrLayershell.exclusionMode: ExclusionMode.Normal
		property alias audioConfVisible: sysControls.sinksVisible
		property bool sinks: true

		Rectangle {
			id: child
			width: 600
			height: 600
			color: S.Theme.get().background
			radius: S.Theme.get().rounded
			ColumnLayout {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.margins: 20
				spacing: 10
				UserBar {}
				SysControls {
					id: sysControls
				}
				ClippingRectangle {
					Layout.fillWidth: true
					implicitHeight: win.audioConfVisible ? audioConf.implicitHeight + 20 : 0
					color: S.Theme.get().foreground
					radius: S.Theme.get().rounded
					Behavior on implicitHeight {
						NumberAnimation {
							duration: 200
							easing.type: Easing.BezierSpline
						}
					}
					ColumnLayout {
						id: audioConf
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.margins: 10
						anchors.top: parent.top
						MButton {
							text: win.sinks ? "Sinks" : "Apps"
							onClicked: {
								win.sinks = !win.sinks;
							}
						}
						Repeater {
							model: S.Audio.sinks
							Rectangle {
								id: sink
								visible: win.sinks
								required property PwNode modelData
								Layout.fillWidth: true
								implicitHeight: sinkRow.implicitHeight
								color: S.Theme.get().foreground2
								radius: S.Theme.get().rounded
								RowLayout {
									id: sinkRow
									anchors.left: parent.left
									anchors.right: parent.right
									anchors.margins: 10

									MButton {
										Layout.preferredWidth: 20
										Layout.preferredHeight: 20
										color: S.Audio.sink?.id == sink.modelData.id ? S.Theme.getAccentColor() : S.Theme.get().foreground
										onClicked: {
											S.Audio.setAudioSink(sink.modelData);
										}
									}

									MText {
										Layout.margins: 10
										text: sink.modelData.description
										Layout.fillWidth: true
										elide: Text.ElideRight
									}
								}
							}
						}
						ScrollView {
							Layout.fillWidth: true
							Layout.maximumHeight: 400
							ColumnLayout {
								anchors.left: parent.left
								anchors.right: parent.right
								Repeater {
									model: S.Audio.sources
									Rectangle {
										id: source
										visible: !win.sinks
										Layout.fillWidth: true
										required property PwNode modelData
										implicitHeight: sourceRow.implicitHeight
										color: S.Theme.get().foreground2
										radius: S.Theme.get().rounded
										RowLayout {
											id: sourceRow
											anchors.left: parent.left
											anchors.right: parent.right
											anchors.margins: 10

											MText {
												Layout.margins: 10
												Layout.fillWidth: true
												text: {
													if (!source.modelData.properties)
														return source.modelData.description;

													if (source.modelData.properties["media.name"])
														return source.modelData.properties["media.name"];

													return source.modelData.description;
												}
												elide: Text.ElideRight
											}
											MSlider {
												Layout.maximumWidth: 200
												Layout.minimumWidth: 200
												Layout.fillWidth: true
												value: source.modelData.audio.volume
												onMoved: {
													source.modelData.audio.volume = this.value;
												}
											}
										}
									}
								}
							}
						}
					}
				}

				Weather {
					color: S.Theme.get().foreground
					implicitHeight: 100
					fontSize: 10
				}
			}
		}

		PropertyAnimation {
			id: anim
			target: child
			property: "y"
			duration: 100
			to: S.Visibilities.screens[win.modelData.name][win.name] ? 0 : child.height
			onRunningChanged: {
				if (this.running)
					return;
				const me = S.Visibilities.screens[win.modelData.name][win.name];
				if (me)
					return;
				if (!me)
					win.visible = false;
			}
		}
		Connections {
			target: S.Visibilities
			function onScreensChanged() {
				const me = S.Visibilities.screens[win.modelData.name][win.name];
				if (me == win.visible)
					return;
				if (win.visible) {
					anim.running = true;
					win.audioConfVisible = false;
					win.sinks = true;
				} else {
					win.visible = true;
					anim.running = true;
				}
			}
		}
		Component.onCompleted: {
			S.Visibilities.addPanel(win.name);
		}
	}
}
