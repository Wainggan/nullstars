
function trigger_setup() {
	static __none = function(){};
	link = undefined;
	trigger_activate = __none;
}

function trigger_run(_target = self) {
	with _target trigger_activate();
}

function trigger_set(_callback, _target = self) {
	with _target trigger_activate = _callback;
}

function trigger_send(_target = self) {
	with _target {
		if link != undefined {
			link.trigger_activate(self);
		}
	}
}

