import Quickshell
import QtQuick
import qs.services

MText {
	property string format: "ddd MMM d hh:mm:ss AP t yyyy"
	text: Time.format(format)
}
