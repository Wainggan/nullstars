
// #macro TILE_SIZE 16
#macro TILE_BIT_OFF_X 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
#macro TILE_BIT_OFF_y 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000

function tilemap_get_tileset_count_pot(tilemap) {
	var tileset = tilemap_get_tileset(tilemap);
	var tilecount = tileset_get_info(tileset).tile_count;
	return power(2, ceil(log2(tilecount)));
}

function tilemap_setup_mask(_tilemap, _offset, _length = 0) {
	var _count = tilemap_get_tileset_count_pot(_tilemap);
	
	tilemap_set_mask(_tilemap, tile_mirror | tile_flip | tile_rotate | (_count - 1));
	
	var _bitoffset = -1;
	while floor(_count) > 0 {
		_count = _count * 0.5;
		_bitoffset += 1;
	}
	
	return _bitoffset;
}

function mask_from(_length) {
	return power(_length, 2) - 1
}

function mask_length(_mask) {
	var _count = _mask
	var _length = 0
	while floor(_count) > 0 {
		_count *= 0.5
		_length++
	}
	return _length
}

function string_mask(_mask) {
	var _str = ""
	while floor(_mask) > 0 {
		_str = (_mask & 1 ? "1" : "0") + _str
		_mask *= 0.5
	}
	return string_repeat("0", abs(string_length(_str) - 31)) + _str
}



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
