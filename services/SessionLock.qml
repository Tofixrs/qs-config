pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.services
import qs.widgets

Singleton {
	id: root

	readonly property bool locked: lock.locked
	readonly property bool secure: lock.secure
	readonly property bool authenticating: pam.active
	readonly property bool responseRequired: pam.responseRequired
	readonly property bool responseVisible: pam.responseVisible
	readonly property string prompt: pam.message
	readonly property bool messageIsError: pam.messageIsError

	property string pamConfig: "login"
	property string response: ""
	property string statusText: ""
	property bool statusError: false

	function clearState(): void {
		root.response = "";
		root.statusText = "";
		root.statusError = false;
	}

	function beginAuth(): bool {
		if (pam.active)
			return true;

		if (!pam.start()) {
			root.statusText = "Unable to start authentication.";
			root.statusError = true;
			return false;
		}

		return true;
	}

	function lockSession(): void {
		if (lock.locked)
			return;

		root.clearState();
		lock.locked = true;
		SystemMetrics.refresh();
		Weather.refreshCurrent();
		root.beginAuth();
	}

	function unlock(): void {
		if (pam.active)
			pam.abort();

		root.clearState();
		lock.locked = false;
	}

	function submit(): void {
		if (!lock.locked)
			return;

		if (!root.beginAuth())
			return;

		if (!pam.responseRequired)
			return;

		const value = root.response;
		root.response = "";
		pam.respond(value);
	}

	IpcHandler {
		target: "sessionLock"

		function lock() {
			root.lockSession();
		}

		function isLocked(): bool {
			return root.locked;
		}
	}

	WlSessionLock {
		id: lock

		onLockedChanged: {
			if (!locked)
				root.clearState();
		}

		surface: Component {
			WlSessionLockSurface {
				LockScreen {}
			}
		}
	}

	PamContext {
		id: pam
		config: root.pamConfig

		onPamMessage: {
			if (message.length === 0) {
				root.statusText = "";
				root.statusError = false;
				return;
			}

			root.statusText = message;
			root.statusError = messageIsError;
		}

		onCompleted: result => {
			switch (result) {
			case PamResult.Success:
				root.statusText = "Authentication successful.";
				root.statusError = false;
				root.unlock();
				break;
			case PamResult.Failed:
				root.response = "";
				root.statusText = pam.message.length > 0 ? pam.message : "Authentication failed.";
				root.statusError = true;
				if (lock.locked)
					root.beginAuth();
				break;
			case PamResult.MaxTries:
				root.response = "";
				root.statusText = "Maximum authentication attempts reached. Retry to start a new session.";
				root.statusError = true;
				break;
			case PamResult.Error:
				root.response = "";
				root.statusText = "PAM returned an internal error.";
				root.statusError = true;
				break;
			}
		}

		onError: error => {
			root.response = "";
			root.statusText = `Authentication backend error: ${error}`;
			root.statusError = true;
		}
	}
}
