import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import qs.widgets
import qs.services

Variants {
	model: Quickshell.screens

	StyledWindow {
	required property ShellScreen modelData
	name: "notifs"
	screen: modelData
	anchors.right: true
	anchors.top: true
	implicitWidth: 500
	implicitHeight: Math.min(500, content.height + 20)

	function onImplicitHeightChanged() {
		console.log(this.implicitHeight)
	}

	ScrollView {
		id: scrollView
		anchors.fill: parent
		contentHeight: content.height + 20
		ListView {
		id: content
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 10
		spacing: 10
		model: ScriptModel {
			values: [...Notif.popups].reverse()
		}
		delegate: Notification {}
		}
	}
	}
}
