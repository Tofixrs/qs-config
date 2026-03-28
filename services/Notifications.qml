pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root

	readonly property alias server: server
	property var notifications: []
	readonly property int count: root.notifications.length
	property var popupNotifications: []
	property var animatedPopups: []
	property int popupDuration: 5000

	function trackNotification(notification): void {
		if (!notification)
			return;
		if (root.notifications.includes(notification))
			return;

		notification.tracked = true;
		root.notifications = [...root.notifications, notification];
		root.showPopup(notification);

		notification.closed.connect(() => {
			root.forgetNotification(notification);
		});
	}

	function forgetNotification(notification): void {
		if (!notification)
			return;
		root.notifications = root.notifications.filter(value => value !== notification);
		root.hidePopup(notification);
	}

	function removeNotification(notification): void {
		if (!notification)
			return;
		root.forgetNotification(notification);
		root.hidePopup(notification);
		notification.tracked = false;
	}

	function dismissAll(): void {
		for (const notification of [...root.notifications]) {
			root.removeNotification(notification);
		}
		root.popupNotifications = [];
		root.animatedPopups = [];
	}

	function showPopup(notification): void {
		if (!notification)
			return;
		if (root.popupNotifications.includes(notification))
			root.hidePopup(notification);
		root.popupNotifications = [notification, ...root.popupNotifications];
	}

	function hasAnimatedPopup(notification): bool {
		return !!notification && root.animatedPopups.includes(notification);
	}

	function markPopupAnimated(notification): void {
		if (!notification || root.animatedPopups.includes(notification))
			return;
		root.animatedPopups = [...root.animatedPopups, notification];
	}

	function hidePopup(notification = null): void {
		if (!notification) {
			root.popupNotifications = [];
			root.animatedPopups = [];
			return;
		}
		root.popupNotifications = root.popupNotifications.filter(value => value !== notification);
		root.animatedPopups = root.animatedPopups.filter(value => value !== notification);
	}

	NotificationServer {
		id: server
		bodySupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		actionsSupported: true
		actionIconsSupported: true
		inlineReplySupported: false
		persistenceSupported: true
		imageSupported: true
		keepOnReload: true

		onNotification: notification => {
			root.trackNotification(notification);
		}
	}
}
