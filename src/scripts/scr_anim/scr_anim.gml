
function AnimLevel(_frames = [], _speed = 0, _loop = -1) constructor {
	frames = _frames;
	speed = _speed;
	loop = _loop
}

function AnimController() constructor {
	
	animations = {};
	current = undefined;
	timer = 0;
	
	__meta_default = {};
	__meta_items = {};
	__cache = 0;
	
	/// adds an AnimLevel
	/// @arg {string} _name
	/// @arg {struct.AnimLevel} _level
	/// @return {struct.AnimController}
	/// @self struct.AnimController
	static add = function(_name, _level) {
		animations[$ _name] = _level;
		return self;
	}
	
	/// sets the current animation
	/// @arg {string} _name
	/// @self struct.AnimController
	static set = function(_name) {
		if current != _name {
			timer = 0;
		}
		current = _name;
	}
	
	/// updates the current animation
	static update = function() {
		timer += animations[$ current].speed;
	}
	
	/// gets an AnimLevel
	/// @arg {string} _name
	/// @return {struct.AnimLevel}
	static extract = function(_name) {
		return animations[$ _name];
	}
	
	/// gets the current frame
	/// @return {real}
	static get = function() {
		var _current = animations[$ current];
		var _frames = _current.frames;
		if _current.loop != -1 {
			if floor(floor(timer) / array_length(_frames)) > _current.loop * array_length(_frames)  {
				return _frames[array_length(_frames) - 1]
			}
		}
		return _frames[floor(timer) % array_length(_frames)];
	}
	
	static meta_default = function(_data){
		__meta_default = _data;
		__cache += 1;
		return self;
	}
	static meta_items = function(_items, _data) {
		for (var i = 0; i < array_length(_items); i++) {
			if __meta_items[$ _items[i]] == undefined
				__meta_items[$ _items[i]] = [];
			array_push(__meta_items[$ _items[i]], _data);
		}
		__cache += 1;
		return self;
	}
	
	static meta = function(){
		
		// avoid unneccessary struct creation
		static __cache_last = -1;
		static __names = undefined;
		if __cache != __cache_last {
			__names = struct_get_names(__meta_default);
			__cache_last = __cache;
		}
		
		// set up default metadata
		var _out = {};
		for (var i = 0; i < array_length(__names); i++) {
			_out[$ __names[i]] = __meta_default[$ __names[i]];
		}
		
		// override defaults with current frame's metadata
		var _datas = __meta_items[$ get()];
		if _datas != undefined {
			for (var j = 0; j < array_length(_datas); j++) {
				
				for (var i = 0; i < array_length(__names); i++) {
					var _item = _datas[j][$ __names[i]];
					
					if _item != undefined _out[$ __names[i]] = _item;
				}
				
			}
		}
		
		return _out;
	}
	
}

