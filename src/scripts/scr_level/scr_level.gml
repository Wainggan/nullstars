
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


// does not support entity defs. should be handled case by case instead
function level_ldtk_field(_field) {
	var _val = _field.__value;
	switch _field.__type {
		case "Point":
								
			_val = {
				x: _val.cx * TILESIZE,
				y: _val.cy * TILESIZE
			};
								
			break;
		case "Color":

			var _r = string_copy(_val, 2, 2);
			var _g = string_copy(_val, 2 + 2, 2);
			var _b = string_copy(_val, 2 + 4, 2);
			_r = hex_to_dec(_r);
			_g = hex_to_dec(_g);
			_b = hex_to_dec(_b);
			_val = make_color_rgb(_r, _g, _b);
			
			break;
		case "EntityRef":
			throw "attempted to parse entityref with level_ldtk_field()"
	}
	return _val
}

function level_ldtk_intgrid(_data, _tilemap) {
	for (var i = 0; i < array_length(_data.intGridCsv); i++) {

		var _t = _data.intGridCsv[i];
		var _t_x = i % _data.__cWid;
		var _t_y = floor(i / _data.__cWid);

		tilemap_set(_tilemap, _t, _t_x, _t_y);

	}
}

function level_ldtk_tiles(_data, _tilemap) {
	for (var i = 0; i < array_length(_data); i++) {

		var _td = _data[i];

		var _t_x = round(_td.px[0] / TILESIZE);
		var _t_y = round(_td.px[1] / TILESIZE);
		var _t = _td.t;

		tilemap_set(_tilemap, _t, _t_x, _t_y);

	}
}

function level_get_vf() {
	static __out = -1;
	if __out != -1 return __out
	vertex_format_begin()
	vertex_format_add_position()
	vertex_format_add_texcoord()
	__out = vertex_format_end()
	return __out
}

function Level() constructor {
	
	loaded = false;
	
	x = 0;
	y = 0;
	width = 0;
	height = 0;
	
	fields = {}
	
	// collisions
	layer = -1;
	tiles = -1;
	
	// front tiles
	layer_front = -1;
	tiles_front = -1;
	
	front_vb = -1;
	
	// background tiles
	layer_back = -1;
	tiles_back = -1;
	
	
	shadow_vb = -1;
	
	// should only be run once, _level struct to be destroyed later
	static init = function(_level) {
		
		var _lv_x = floor(_level.worldX / TILESIZE),
			_lv_y = floor(_level.worldY / TILESIZE),
			_lv_w = floor(_level.pxWid / TILESIZE),
			_lv_h = floor(_level.pxHei / TILESIZE);
	
		x = _lv_x * TILESIZE;
		y = _lv_y * TILESIZE;
		width = _lv_w * TILESIZE;
		height = _lv_h * TILESIZE;
		
		for (var i_field = 0; i_field < array_length(_level.fieldInstances); i_field++) {
			var _f = _level.fieldInstances[i_field]
			fields[$ _f.__identifier] = level_ldtk_field(_f);
		}
		
		layer = layer_create(0)
		tiles = layer_tilemap_create(layer, x, y, tl_debug, width / TILESIZE, height / TILESIZE);
		
		layer_front = layer_create(0)
		tiles_front = layer_tilemap_create(layer_front, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
				
		layer_back = layer_create(110)
		tiles_back = layer_tilemap_create(layer_back, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
		
		for (var i_layer = 0; i_layer < array_length(_level.layerInstances); i_layer++) {
			var _layer = _level.layerInstances[i_layer];

			switch _layer.__identifier {
				
				case "Tiles":
					// construct stupid vertex buffer stuff
					// the things i do for 2 pixels

					front_vb = vertex_create_buffer()
					
					vertex_begin(front_vb, level_get_vf())
					
					var _ts_info = tileset_get_info(tl_tiles);
					var _ts_width = _ts_info.tile_width + 2 * _ts_info.tile_horizontal_separator;
					var _ts_height = _ts_info.tile_height + 2 * _ts_info.tile_vertical_separator;
					
					var _tex_rx = texture_get_texel_width(_ts_info.texture)
					var _tex_ry = texture_get_texel_height(_ts_info.texture)
					
					var _uv_x = tileset_get_uvs(tl_tiles)[0]
					var _uv_y = tileset_get_uvs(tl_tiles)[1]
					
					for (var i = 0; i < array_length(_layer.autoLayerTiles); i++) {
						var _td = _layer.autoLayerTiles[i];
						
						var _t = _td.t;
						var _t_x = _td.px[0];
						var _t_y = _td.px[1];
						
						var _ts_tile_x = (_t mod _ts_info.tile_columns) * _ts_width;
						var _ts_tile_y = (_t div _ts_info.tile_columns) * _ts_height;
						
						var _uv_t_x = _uv_x + _ts_tile_x * _tex_rx
						var _uv_t_y = _uv_y + _ts_tile_y * _tex_ry
						
						// tri 1
						vertex_position(front_vb, _t_x, _t_y)
						vertex_texcoord(front_vb, _uv_t_x, _uv_t_y)
						
						vertex_position(front_vb, _t_x + TILESIZE, _t_y)
						vertex_texcoord(front_vb, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y)
						
						vertex_position(front_vb, _t_x + TILESIZE, _t_y + TILESIZE)
						vertex_texcoord(front_vb, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry)
						
						// tri 2
						vertex_position(front_vb, _t_x, _t_y)
						vertex_texcoord(front_vb, _uv_t_x, _uv_t_y)
						
						vertex_position(front_vb, _t_x, _t_y + TILESIZE)
						vertex_texcoord(front_vb, _uv_t_x, _uv_t_y + TILESIZE * _tex_ry)
						
						vertex_position(front_vb, _t_x + TILESIZE, _t_y + TILESIZE)
						vertex_texcoord(front_vb, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry)
						
					}
					
					vertex_end(front_vb)
					
					show_debug_message("complete")
					
				
					break;
				case "Background": 
					level_ldtk_tiles(_layer.autoLayerTiles, tiles_back);
					break;
				
			}
		}
	}
	
	static load = function() {
		
		if loaded return;
		loaded = true;
		
	}
	
	static unload = function() {
		
		if !loaded return;
		loaded = false;
	
	}
	
	
}


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
	
	static _pad = 16
	
	static __out = []
	static __cache_x = 0
	static __cache_y = 0
	
	if __cache_x != _cam.x || __cache_y != _cam.y {
		__out = []
		__cache_x = _cam.x
		__cache_y = _cam.y
		
		for (var i = 0; i < array_length(level.levels); i++) {
			var _lvl = level.levels[i];
			if rectangle_in_rectangle(
					_cam.x - _pad, _cam.y - _pad,
					_cam.x + _cam.w + _pad, _cam.y + _cam.h + _pad,
				
					_lvl.x, _lvl.y,
					_lvl.x + _lvl.width,
					_lvl.y + _lvl.height) {
				array_push(__out, _lvl)
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
