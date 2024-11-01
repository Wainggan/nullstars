
enum Log {
	user,
	note,
	warn,
	error,
}

function Logger() constructor {
	
	point = Log.user;
	messages = [];
	anim = 0;
	
	static write = function (_level, _message) {
		if _level <= point {
			show_debug_message($"{_level} :: {_message}");
			array_insert(messages, 0, _message);
		}
	}
	
	static update = function () {
		if array_length(messages) == 0 {
			anim = 0;
			return;
		}
		anim = approach(anim, 1, 1 / (60 * 4));
		if anim == 1 {
			array_pop(messages);
			anim = 0;
		}
	}
	
}

global.logger = new Logger();
global.logger.point = Log.error;

function log(_level, _message) {
	global.logger.write(_level, _message);
}
function log_level(_level) {
	global.logger.point = _level;
}

