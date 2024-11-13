
function Variable(_default) {
	
	def = _default;
	value = def;
	priority = 0;
	
	static start = function() {
		value = def;
		priority = 0;
	}
	
	static edit = function(_priority, _callback) {
		if priority < _priority return;
		priority = _priority;
		value = _callback(value);
	}
	
}

function Updater() {
	
	variables = {};
	
	static add = function(_var) {
		array_push(variables, _var);
	}
	
	static start = function() {
		var _names = struct_get_names(variables);
		for (var i = 0; i < array_length(_names); i++) {
			variables[$ _names[i]].start();
		}
	}
	
	static edit = function(_name, _callback) {
		variables[$ _name].edit(_callback);
	}
	
}




