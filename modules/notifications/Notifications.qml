import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
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
        implicitHeight: list.height + 20

        ColumnLayout {
            id: list
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.margins: 10
            spacing: 5
            Repeater {
                model: ScriptModel {
                    values: [...Notif.popups].reverse()
                }
                Notification {}
            }
        }
    }
}
