
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
	
	static add = function(_name, _level){
		animations[$ _name] = _level;
		return self;
	}
	
	static set = function(_name){
		if current != _name {
			timer = 0;
		}
		current = _name;
	}
	
	static update = function(){
		timer += animations[$ current].speed;
	}
	
	static extract = function(_name){
		return animations[$ _name];
	}
	
	static get = function(){
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
		return self;
	}
	static meta_items = function(_items, _data) {
		for (var i = 0; i < array_length(_items); i++) {
			if __meta_items[$ _items[i]] == undefined
				__meta_items[$ _items[i]] = [];
			array_push(__meta_items[$ _items[i]], _data);
		}
		return self;
	}
	
	static meta = function(){
		var _out = {};
		var _names = struct_get_names(__meta_default);
		for (var i = 0; i < array_length(_names); i++) {
			_out[$ _names[i]] = __meta_default[$ _names[i]];
		}
		var _datas = __meta_items[$ get()];
		if _datas != undefined {
			for (var j = 0; j < array_length(_datas); j++) {
				var _names = struct_get_names(_datas[j]);
				for (var i = 0; i < array_length(_names); i++) {
					_out[$ _names[i]] = _datas[j][$ _names[i]];
				}
			}
		}
		return _out;
	}
	
}

