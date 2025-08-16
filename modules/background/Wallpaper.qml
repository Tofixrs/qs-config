import QtQuick
import QtMultimedia
import qs.services
import qs.utils

Item {
	id: root
	anchors.fill: parent
	property Item wallPaperVisible
	function showingVid() {
		return root.wallPaperVisible == vidOne || root.wallPaperVisible == vidTwo;
	}

	AnimatedImage {
		id: one
		anchors.fill: parent
		opacity: 0
		fillMode: Image.PreserveAspectCrop
		onStatusChanged: playing = (status == AnimatedImage.Ready)
	}

	AnimatedImage {
		id: two
		anchors.fill: parent
		opacity: 0
		fillMode: Image.PreserveAspectCrop
		onStatusChanged: playing = (status == AnimatedImage.Ready)
	}
	Video {
		id: vidOne
		anchors.fill: parent
		fillMode: VideoOutput.PreserveAspectCrop
		loops: MediaPlayer.Infinite
		autoPlay: true
		opacity: 0
	}
	Video {
		id: vidTwo
		anchors.fill: parent
		opacity: 0
		fillMode: VideoOutput.PreserveAspectCrop
		loops: MediaPlayer.Infinite
		autoPlay: true
	}

	SequentialAnimation {
		id: fadeAnim
		running: false

		PropertyAnimation {
			id: fadeOut
			target: one
			property: "opacity"
			to: 0 // Fade out the first image
			duration: 200
		}

		PropertyAnimation {
			id: fadeIn
			target: two
			property: "opacity"
			to: 1 // Fade in the second image
			duration: 200
		}
	}

	Connections {
		target: Wallpaper
		function onWallpaperChanged() {
			const src = `${Paths.wallpaper}/${Wallpaper.currentWallpaper}`;
			if (root.wallPaperVisible == null) {
				if (Wallpaper.isCurrentVid()) {
					root.wallPaperVisible = vidOne;
					vidOne.source = src;
					vidOne.opacity = 1;
				} else {
					root.wallPaperVisible = one;
					one.source = src;
					one.opacity = 1;
				}
			} else {
				let toShow;
				fadeOut.target = root.wallPaperVisible;
				if (Wallpaper.isCurrentVid()) {
					switch (root.wallPaperVisible) {
					case vidTwo:
					case one:
					case two:
						toShow = vidOne;
						break;
					case vidOne:
						toShow = vidTwo;
					}

					toShow.source = src;
					fadeIn.target = toShow;
					fadeAnim.start();
					root.wallPaperVisible = toShow;
				} else {
					switch (root.wallPaperVisible) {
					case one:
						toShow = two;
						break;
					case vidOne:
					case vidTwo:
					case two:
						toShow = one;
						break;
					}
					toShow.source = src;
					fadeIn.target = toShow;
					fadeAnim.start();
					root.wallPaperVisible = toShow;
				}
			}
		}
	}
}
