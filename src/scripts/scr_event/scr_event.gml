
function Event() constructor {
	
	events = {};
	
	static add = function(_name, _callback){
		events[$ _name] = _callback;
		return self;
	}
	
	static call = function(_name){
		events[$ _name](self);
	}
	
}
