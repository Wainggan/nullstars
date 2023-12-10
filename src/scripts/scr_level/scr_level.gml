
function game_level_get(_x, _y) {
	for (var i = 0; i < array_length(level.levels); i++) {
		var _lvl = level.levels[i];
		if point_in_rectangle(
				_x, _y, 
				_lvl.x, _lvl.y,
				_lvl.x + _lvl.width,
				_lvl.y + _lvl.height) {
			return _lvl;
		}
	}
	return undefined;
}
function game_level_onscreen() {
	var _cam = game_camera_get();
	var _arr = []
	
	for (var i = 0; i < array_length(level.levels); i++) {
		var _lvl = level.levels[i];
		if rectangle_in_rectangle(
				_cam.x, _cam.y,
				_cam.x + _cam.w, _cam.y + _cam.h,
				
				_lvl.x, _lvl.y,
				_lvl.x + _lvl.width,
				_lvl.y + _lvl.height) {
			array_push(_arr, _lvl)
		}
	}
	return _arr;
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
