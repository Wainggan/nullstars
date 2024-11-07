
function trigger_setup() {
	static __none = function(){};
	link = [];
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
		for (var i = 0; i < array_length(link); i++) {
			trigger_run(link[i]);
		}
	}
}

