
function game_level_get(_x, _y) {
	for (var i = 0; i < array_length(level.levels); i++) {
		var _lvl = level.levels[i];
		if point_in_rectangle(
				_x, _y, 
				_lvl.x, _lvl.y,
				_lvl.x + _lvl.width,
				_lvl.y + _lvl.height) {
			return _lvl.part;
		}
	}
	return undefined;
}
function game_level_onscreen() {
	var _cam = game_camera_get();
	
	static _pad = 16
	
	static __out = []
	static __cache_x = 0
	static __cache_y = 0
	
	if __cache_x != _cam.x || __cache_y != _cam.y {
		__out = []
		__cache_x = _cam.x
		__cache_y = _cam.y
		
		for (var i = 0; i < array_length(level.loaded); i++) {
			var _lvl = level.loaded[i];
			if rectangle_in_rectangle(
					_cam.x - _pad, _cam.y - _pad,
					_cam.x + _cam.w + _pad, _cam.y + _cam.h + _pad,
				
					_lvl.x, _lvl.y,
					_lvl.x + _lvl.width,
					_lvl.y + _lvl.height) {
				array_push(__out, _lvl.part)
			}
		}
	}
	
	return __out;
}

function game_level_get_biome(_x, _y) {
	var _lvl = game_level_get(_x, _y);
	if _lvl == undefined return "";
	return _lvl.fields.biome;
}
function game_level_get_background(_x, _y) {
	var _lvl = game_level_get(_x, _y);
	if _lvl == undefined return "";
	return _lvl.fields.background;
}
function game_level_get_music(_x, _y) {
	var _lvl = game_level_get(_x, _y);
	if _lvl == undefined return undefined;
	if _lvl.fields.music == pointer_null return undefined;
	return _lvl.fields.music;
}
