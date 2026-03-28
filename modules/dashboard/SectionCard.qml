import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets

SurfaceCard {
	id: root

	default property alias content: contentColumn.data
	property alias headerItem: headerLoader.sourceComponent
	property bool expanded: false

	cardColor: Theme.foreground
	padding: 10
	contentSpacing: 10

	ColumnLayout {
		id: contentWrap
		Layout.fillWidth: true
		spacing: 10

		Loader {
			id: headerLoader
			Layout.fillWidth: true
		}

		ColumnLayout {
			id: contentColumn
			Layout.fillWidth: true
			spacing: 8
			opacity: root.expanded ? 1 : 0
			visible: opacity > 0

			Behavior on opacity {
				NumberAnimation {
					duration: Theme.motionBase
					easing.type: Easing.OutCubic
				}
			}
		}
	}
}
