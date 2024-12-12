

/// way of managing an actor's abilities
function Event() constructor {
	
	/// @ignore
	events = {};
	
	/// adds a callback
	/// @arg {string} _name
	/// @arg {function} _callback
	/// @return {struct.Event}
	/// @self struct.Event
	static add = function(_name, _callback) {
		events[$ _name] = _callback;
		return self;
	}
	
	/// runs a callback
	/// @arg {string} _name
	/// @arg {any} _arg0
	/// @arg {any} _arg1
	/// @arg {any} _arg2
	/// @arg {any} _arg3
	/// @self struct.Event
	static call = function(
			_name, 
			_arg0 = undefined, 
			_arg1 = undefined,
			_arg2 = undefined,
			_arg3 = undefined,
			) {
		if events[$ _name] != undefined {
			events[$ _name](_arg0, _arg1, _arg2, _arg3);
		}
	}
	
}
