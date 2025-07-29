pragma ComponentBehavior: Bound
import QtQuick
import qs.services
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import qs.widgets
import Quickshell.Services.Notifications

Item {
    id: root
    property real fontSize: 15
    required property Notif.Notif modelData
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    property color color: Theme.get().background
    property bool shadow: true
    Layout.fillWidth: true
    implicitHeight: inner.height
    function close() {
        modelData.notification.expire();
    }

    Rectangle {
        id: inner
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        implicitHeight: content.height + 20
        x: 500
        radius: Theme.get().rounded

        Component.onCompleted: x = 0

        color: root.color
        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [Easing.OutCubic]
            }
        }

        ColumnLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            RowLayout {
                Layout.alignment: Qt.AlignTop
                IconImage {
                    source: Quickshell.iconPath(root.modelData.appIcon, "image-missing")
                    implicitSize: parent.height
                }
                MText {
                    text: root.modelData.summary
                    font.pointSize: root.fontSize * 4 / 3
                    Layout.fillWidth: true
                }

                MButton {
                    text: "close"
                    font.family: "Material Symbols Rounded"
                    font.pointSize: root.fontSize * 4 / 3
                    radius: height
                    onClicked: {
                        root.modelData.notification.dismiss();
                    }
                }
            }
            MText {
                wrapMode: Text.WrapAnywhere
                text: root.modelData.body
                font.pointSize: root.fontSize
                Layout.maximumWidth: parent.width
            }

            ColumnLayout {
                Repeater {
                    model: root.modelData.actions
                    MButton {
                        Layout.fillWidth: true
                        required property NotificationAction modelData
                        font.pointSize: root.fontSize
                        text: modelData.text
                        onClicked: {
                            modelData.invoke();
                        }
                    }
                }
            }
        }
    }

    RectangularShadow {
        visible: root.shadow
        anchors.fill: inner
        radius: inner.radius
        blur: 20
        z: -1
        spread: 1
        color: Qt.darker(inner.color, 1.6)
    }
}
