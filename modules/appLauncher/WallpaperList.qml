pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../../utils"

Repeater {
    id: list
    function toggle() {
    }
    required property string mode
    required property string inputValue
    model: {
        if (mode != "wallpaper")
            return [];
        return Wallpaper.wallpapers.filter(v => v.toLowerCase().includes(list.inputValue)).slice(0, 5);
    }

    Entry {
        required property string modelData
        text: modelData
        iconSource: {
            if (modelData.endsWith("webm") || modelData.endsWith("mp4")) {
                return Quickshell.iconPath("multimedia-video-player-symbolic");
            }
            return `${Paths.wallpaper}/${modelData}`;
        }
        iconWidth: (height * 16) / 9

        onSelected: {
            Wallpaper.setWallpaper(modelData);
            list.toggle();
        }
    }
}
