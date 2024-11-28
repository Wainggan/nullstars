
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

function level_get_instance(_uid) {
	return global.entities[$ _uid];
}

function level_ldtk_field_item(_val, _type) {
	switch _type {
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
			_val = _val.entityIid
			break;
	}
	return _val;
}

// does not support entity defs. should be handled case by case instead
function level_ldtk_field(_field, _x = 0, _y = 0) {
	var _val = _field.__value;
	var _item =  level_ldtk_field_item(_val, _field.__type);
	// messy hack
	if _field.__type == "Point" {
		_item.x += _x;
		_item.y += _y;
	}
	// this fucking sucks
	// what the fuck is wrong with you?
	if string_starts_with(_field.__type, "Array") {
		static __cut = ["Array<", ">"];
		var _innertype = string_trim(_field.__type, __cut);
		var _arr = [];
		for (var i = 0; i < array_length(_field.__value); i++) {
			var _item_arr = level_ldtk_field_item(_field.__value[i], _innertype);
			if _innertype == "Point" {
				_item_arr.x += _x;
				_item_arr.y += _y;
			}
			array_push(_arr, _item_arr);
		}
		_item = _arr;
	}
	return _item;
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

function level_ldtk_tiles_window(_data, _tilemap_normal, _tilemap_window) {
	for (var i = 0; i < array_length(_data); i++) {

		var _td = _data[i];

		var _t_x = round(_td.px[0] / TILESIZE);
		var _t_y = round(_td.px[1] / TILESIZE);
		var _t = _td.t;
		
		var _p_w = (sprite_get_width(spr_tiles) / TILESIZE);

		var _p_x = _t % _p_w
		var _p_y = floor(_t / _p_w)
		
		if 4 <= _p_x && _p_x <= 7 && 13 <= _p_y && _p_y <= 20 {
			tilemap_set(_tilemap_window, _t, _t_x, _t_y);
		} else {
			tilemap_set(_tilemap_normal, _t, _t_x, _t_y);
		}

	}
}

function level_ldtk_buffer(_data, _buffer) {
	vertex_begin(_buffer, level_get_vf())
	
	var _ts_info = tileset_get_info(tl_tiles);
	var _ts_width = _ts_info.tile_width + 2 * _ts_info.tile_horizontal_separator;
	var _ts_height = _ts_info.tile_height + 2 * _ts_info.tile_vertical_separator;

	var _tex_rx = texture_get_texel_width(_ts_info.texture)
	var _tex_ry = texture_get_texel_height(_ts_info.texture)

	var _uv_x = tileset_get_uvs(tl_tiles)[0]
	var _uv_y = tileset_get_uvs(tl_tiles)[1]

	for (var i = 0; i < array_length(_data); i++) {
		var _td = _data[i];

		var _t = _td.t;
		var _t_x = _td.px[0];
		var _t_y = _td.px[1];

		var _ts_tile_x = (_t mod _ts_info.tile_columns) * _ts_width;
		var _ts_tile_y = (_t div _ts_info.tile_columns) * _ts_height;

		var _uv_t_x = _uv_x + _ts_tile_x * _tex_rx
		var _uv_t_y = _uv_y + _ts_tile_y * _tex_ry

		// tri 1
		vertex_position(_buffer, _t_x, _t_y)
		vertex_texcoord(_buffer, _uv_t_x, _uv_t_y)

		vertex_position(_buffer, _t_x + TILESIZE, _t_y)
		vertex_texcoord(_buffer, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y)

		vertex_position(_buffer, _t_x + TILESIZE, _t_y + TILESIZE)
		vertex_texcoord(_buffer, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry)

		// tri 2
		vertex_position(_buffer, _t_x, _t_y)
		vertex_texcoord(_buffer, _uv_t_x, _uv_t_y)

		vertex_position(_buffer, _t_x, _t_y + TILESIZE)
		vertex_texcoord(_buffer, _uv_t_x, _uv_t_y + TILESIZE * _tex_ry)

		vertex_position(_buffer, _t_x + TILESIZE, _t_y + TILESIZE)
		vertex_texcoord(_buffer, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry)

	}

	vertex_end(_buffer)
}


global.UNPACKPOINTOFFSET_X = 0;
global.UNPACKPOINTOFFSET_Y = 0;

/// @arg {id.Buffer} _buffer
function level_unpack_bin_field(_buffer) {
	var _name = buffer_read(_buffer, buffer_string);
	var _value = level_unpack_bin_field_value(_buffer);
	
	return {
		name: _name,
		value: _value,
	};
}

function level_unpack_bin_field_value(_buffer) {
	
	var _type = buffer_read(_buffer, buffer_u8);
	
	var _value;
	switch _type {
		case 0x00: {
			_value = undefined;
		} break;
		case 0x01: {
			_value = buffer_read(_buffer, buffer_s32);
		} break;
		case 0x02: {
			_value = buffer_read(_buffer, buffer_f64);
		} break;
		case 0x03: {
			_value = buffer_read(_buffer, buffer_u8);
		} break;
		case 0x04: {
			_value = buffer_read(_buffer, buffer_string);
		} break;
		case 0x05: {
			var _r = buffer_read(_buffer, buffer_u8);
			var _g = buffer_read(_buffer, buffer_u8);
			var _b = buffer_read(_buffer, buffer_u8);
			_value = make_color_rgb(_r, _g, _b);
		} break;
		case 0x06: {
			var _x = buffer_read(_buffer, buffer_u32);
			var _y = buffer_read(_buffer, buffer_u32);
			// oooohhhh hoho this is a fucking terrible idea
			// quite devious ill say
			_value = {
				x: _x * TILESIZE + global.UNPACKPOINTOFFSET_X,
				y: _y * TILESIZE + global.UNPACKPOINTOFFSET_Y,
			};
		} break;
		case 0x07: {
			_value = buffer_read(_buffer, buffer_string);
		} break;
		case 0xff: {
			var _length = buffer_read(_buffer, buffer_u8);
			var _array = array_create(_length);
			for (var i = 0; i < _length; i++) {
				_array[i] = level_unpack_bin_field_value(_buffer);
			}
			_value = _array;
		} break;
		default: {
			throw "broked";
		}
	}
	
	return _value;
}

function level_unpack_bin_room(_buffer) {
	var _header = level_unpack_bin_room_header(_buffer);
	var _content = level_unpack_bin_room_content(_buffer);
	
	return {
		header: _header,
		content: _content,
	};
}

function level_unpack_bin_room_header(_buffer) {
	
	var _name = buffer_read(_buffer, buffer_string);
	var _id = buffer_read(_buffer, buffer_string);
	
	var _x = buffer_read(_buffer, buffer_u32);
	var _y = buffer_read(_buffer, buffer_u32);
	var _width = buffer_read(_buffer, buffer_u32);
	var _height = buffer_read(_buffer, buffer_u32);
	
	return {
		name: _name,
		id: _id,
		x: _x, y: _y,
		width: _width, height: _height,
	};
}

function level_unpack_bin_room_content(_buffer) {
	
	var _layers_count = buffer_read(_buffer, buffer_u8);
	var _layers = {};
	for (var i_layer = 0; i_layer < _layers_count; i_layer++) {
		var _temp = level_unpack_bin_layer(_buffer)
		_layers[$ _temp.name] = _temp;
	}
	
	var _fields_count = buffer_read(_buffer, buffer_u8);
	var _fields = {};
	for (var i_field = 0; i_field < _fields_count; i_field++) {
		var _temp = level_unpack_bin_field(_buffer);
		_fields[$ _temp.name] = _temp.value;
	}
	
	return {
		layers: _layers,
		fields: _fields,
	};
}

function level_unpack_bin_toc(_buffer) {
	var _object = buffer_read(_buffer, buffer_string);
	var _id = buffer_read(_buffer, buffer_string);
	
	var _x = buffer_read(_buffer, buffer_u32);
	var _y = buffer_read(_buffer, buffer_u32);
	var _width = buffer_read(_buffer, buffer_u32);
	var _height = buffer_read(_buffer, buffer_u32);
	
	var _field_count = buffer_read(_buffer, buffer_u8);
	var _fields = {};
	for (var i_field = 0; i_field < _field_count; i_field++) {
		var _temp = level_unpack_bin_field(_buffer);
		_fields[$ _temp.name] = _temp.value;
	}
	
	return {
		object: _object,
		id: _id,
		x: _x, y: _y,
		width: _width, height: _height,
		fields: _fields,
	};
}

function level_unpack_bin_main(_buffer) {
	
	var _room_count = buffer_read(_buffer, buffer_u32);
	var _rooms = array_create(_room_count);
	for (var i_room = 0; i_room < _room_count; i_room++) {
		_rooms[i_room] = level_unpack_bin_room_header(_buffer);
	}
	
	var _toc_count = buffer_read(_buffer, buffer_u32);
	var _toc = array_create(_toc_count);
	for (var i_toc = 0; i_toc < _toc_count; i_toc++) {
		_toc[i_toc] = level_unpack_bin_toc(_buffer);
	}
	
	return {
		rooms: _rooms,
		toc: _toc,
	};
}

function level_unpack_bin_layer(_buffer) {
	
	var _name = buffer_read(_buffer, buffer_string);
	
	var _type = buffer_read(_buffer, buffer_u8);
	
	var _pointer = undefined;
	var _entities = undefined;
	
	switch _type {
		case 0x01: {
			_pointer = buffer_tell(_buffer);
			var _length = buffer_read(_buffer, buffer_u32);
			repeat _length {
				buffer_read(_buffer, buffer_u8);
			}
		} break;
		case 0x02: {
			_pointer = buffer_tell(_buffer);
			var _length = buffer_read(_buffer, buffer_u32);
			repeat _length {
				buffer_read(_buffer, buffer_u32);
				buffer_read(_buffer, buffer_s32);
				buffer_read(_buffer, buffer_s32);
			}
		} break;
		case 0x03: {
			_pointer = buffer_tell(_buffer);
			var _length = buffer_read(_buffer, buffer_u32);
			_entities = array_create(_length);
			for (var i = 0; i < _length; i++) {
				_entities[i] = level_unpack_bin_entity(_buffer);
			}
		} break;
		default: {
			throw $"huh {_type}";
		}
	}
	
	return {
		name: _name,
		pointer: _pointer,
		entities: _entities,
	};
}

function level_unpack_bin_entity(_buffer) {
	var _name = buffer_read(_buffer, buffer_string);
	var _id = buffer_read(_buffer, buffer_string);
	
	var _tags_count = buffer_read(_buffer, buffer_u8);
	var _tags = array_create(_tags_count);
	for (var i = 0; i < _tags_count; i++) {
		_tags[i] = buffer_read(_buffer, buffer_string);
	}
	
	var _x = buffer_read(_buffer, buffer_u32);
	var _y = buffer_read(_buffer, buffer_u32);
	var _width = buffer_read(_buffer, buffer_u32);
	var _height = buffer_read(_buffer, buffer_u32);
	
	var _fields_count = buffer_read(_buffer, buffer_u8);
	var _fields = {};
	for (var i = 0; i < _fields_count; i++) {
		var _temp = level_unpack_bin_field(_buffer);
		_fields[$ _temp.name] = _temp.value;
	}
	
	return {
		name: _name,
		id: _id,
		tags: _tags,
		x: _x, y: _y,
		width: _width, height: _height,
		fields: _fields,
	};
}

/// @arg {id.Buffer} _buffer
/// @arg {real} _at
/// @arg {id.TileMapElement} _tilemap
function level_unpack_bin_layer_grid(_buffer, _at, _tilemap) {
	
	buffer_seek(_buffer, buffer_seek_start, _at);
	var _count = buffer_read(_buffer, buffer_u32);
	
	var _w = tilemap_get_width(_tilemap);
	
	for (var i_tile = 0; i_tile < _count; i_tile++) {
		var _tile = buffer_read(_buffer, buffer_u8);
		tilemap_set(_tilemap, _tile, i_tile mod _w, i_tile div _w);
	}
	
}

/// @arg {id.Buffer} _buffer
/// @arg {real} _at
/// @arg {id.TileMapElement} _tilemap
function level_unpack_bin_layer_free_map(_buffer, _at, _tilemap) {
	
	buffer_seek(_buffer, buffer_seek_start, _at);
	var _count = buffer_read(_buffer, buffer_u32);
	
	repeat _count {
		var _t = buffer_read(_buffer, buffer_u32);
		var _t_x = round(buffer_read(_buffer, buffer_s32) / TILESIZE);
		var _t_y = round(buffer_read(_buffer, buffer_s32) / TILESIZE);

		tilemap_set(_tilemap, _t, _t_x, _t_y);
	}
	
}

/// @arg {id.Buffer} _buffer
/// @arg {real} _at
/// @arg {id.TileMapElement} _tilemap_normal
/// @arg {id.TileMapElement} _tilemap_clear
function level_unpack_bin_layer_free_map_filtered(_buffer, _at, _tilemap_normal, _tilemap_clear) {
	
	buffer_seek(_buffer, buffer_seek_start, _at);
	var _count = buffer_read(_buffer, buffer_u32);
	
	repeat _count {
		var _t = buffer_read(_buffer, buffer_u32);
		var _t_x = round(buffer_read(_buffer, buffer_s32) / TILESIZE);
		var _t_y = round(buffer_read(_buffer, buffer_s32) / TILESIZE);
		
		var _p_w = sprite_get_width(spr_tiles) / TILESIZE;
		var _p_x = _t mod _p_w;
		var _p_y = _t div _p_w;
		
		if 4 <= _p_x && _p_x <= 7 && 13 <= _p_y && _p_y <= 20 {
			tilemap_set(_tilemap_clear, _t, _t_x, _t_y);
		} else {
			tilemap_set(_tilemap_normal, _t, _t_x, _t_y);
		}
	}
	
}

/// @arg {id.Buffer} _buffer
/// @arg {real} _at
/// @arg {id.VertexBuffer} _vertex
function level_unpack_bin_layer_free_vertex(_buffer, _at, _vertex) {
	
	buffer_seek(_buffer, buffer_seek_start, _at);
	var _count = buffer_read(_buffer, buffer_u32);
	
	vertex_begin(_vertex, level_get_vf());

	var _ts_info = tileset_get_info(tl_tiles);
	var _ts_width = _ts_info.tile_width + 2 * _ts_info.tile_horizontal_separator;
	var _ts_height = _ts_info.tile_height + 2 * _ts_info.tile_vertical_separator;

	var _tex_rx = texture_get_texel_width(_ts_info.texture);
	var _tex_ry = texture_get_texel_height(_ts_info.texture);

	var _uv_x = tileset_get_uvs(tl_tiles)[0];
	var _uv_y = tileset_get_uvs(tl_tiles)[1];

	repeat _count {
		var _t = buffer_read(_buffer, buffer_u32);
		var _t_x = buffer_read(_buffer, buffer_s32);
		var _t_y = buffer_read(_buffer, buffer_s32);

		var _ts_tile_x = (_t mod _ts_info.tile_columns) * _ts_width;
		var _ts_tile_y = (_t div _ts_info.tile_columns) * _ts_height;

		var _uv_t_x = _uv_x + _ts_tile_x * _tex_rx;
		var _uv_t_y = _uv_y + _ts_tile_y * _tex_ry;

		// tri 1
		vertex_position(_vertex, _t_x, _t_y);
		vertex_texcoord(_vertex, _uv_t_x, _uv_t_y);

		vertex_position(_vertex, _t_x + TILESIZE, _t_y);
		vertex_texcoord(_vertex, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y);

		vertex_position(_vertex, _t_x + TILESIZE, _t_y + TILESIZE);
		vertex_texcoord(_vertex, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry);

		// tri 2
		vertex_position(_vertex, _t_x, _t_y);
		vertex_texcoord(_vertex, _uv_t_x, _uv_t_y);

		vertex_position(_vertex, _t_x, _t_y + TILESIZE);
		vertex_texcoord(_vertex, _uv_t_x, _uv_t_y + TILESIZE * _tex_ry);

		vertex_position(_vertex, _t_x + TILESIZE, _t_y + TILESIZE);
		vertex_texcoord(_vertex, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry);
	}
	
	vertex_end(_vertex);
	
}


/// @return {id.VertexFormat}
function level_get_vf() {
	static __out = -1;
	if __out != -1 return __out
	vertex_format_begin()
	vertex_format_add_position()
	vertex_format_add_texcoord()
	__out = vertex_format_end()
	return __out
}
/// @return {id.VertexFormat}
function level_get_vf_shadows() {
	static __out = -1;
	if __out != -1 return __out;
	vertex_format_begin();
	vertex_format_add_position_3d();
	__out = vertex_format_end();
	return __out
}

global.entities_toc = {}
global.entities = {}

function Level() constructor {
	
	loaded = false;
	
	x = 0;
	y = 0;
	width = 0;
	height = 0;
	
	file = -1;
	
	fields = {}
	
	// collisions
	layer = -1;
	tiles = -1;
	
	vb_front = -1;
	
	// decor tiles
	layer_decor = -1;
	tiles_decor = -1;
	
	// decor under tiles
	layer_decor_under = -1;
	tiles_decor_under = -1;
	
	// decor above tiles
	layer_tiles_above = -1;
	tiles_tiles_above = -1;
	
	// decor below tiles
	vb_tiles_below = -1;
	
	// background tiles
	layer_back = -1;
	tiles_back = -1;
	
	// background glass tiles
	layer_back_glass = -1;
	tiles_back_glass = -1;
	
	// spike tiles
	layer_spike = -1;
	tiles_spike = -1;
	
	// shadows
	shadow_vb = -1;
	
	/// run once after having created Level()
	static init = function(_level, _file) {
		
		var _lv_x = _level.x div TILESIZE,
			_lv_y = _level.y div TILESIZE,
			_lv_w = _level.width div TILESIZE,
			_lv_h = _level.height div TILESIZE;
	
		x = _lv_x * TILESIZE;
		y = _lv_y * TILESIZE;
		width = _lv_w * TILESIZE;
		height = _lv_h * TILESIZE;
		
		var _time = get_timer();
		
		var _buffer = buffer_load(_file);
			
		show_debug_message("level: file: {0}", (get_timer() - _time) / 1000)
		
		_time = get_timer();
		
		global.UNPACKPOINTOFFSET_X = x;
		global.UNPACKPOINTOFFSET_Y = y;
		var _info = level_unpack_bin_room(_buffer);
		global.UNPACKPOINTOFFSET_X = 0;
		global.UNPACKPOINTOFFSET_Y = 0;
		
		show_debug_message("level: unpack: {0}", (get_timer() - _time) / 1000)
		
		_time = get_timer();

		fields = _info.content.fields;
		
		layer = layer_create(0);
		layer_set_visible(layer, false);
		tiles = layer_tilemap_create(layer, x, y, tl_debug, _lv_w, _lv_h);
		level_unpack_bin_layer_grid(_buffer, _info.content.layers[$ "Collisions"].pointer, tiles);
		
		vb_front = vertex_create_buffer();
		level_unpack_bin_layer_free_vertex(_buffer, _info.content.layers[$ "Tiles"].pointer, vb_front);
		
		vb_tiles_below = vertex_create_buffer();
		level_unpack_bin_layer_free_vertex(_buffer, _info.content.layers[$ "TilesBelow"].pointer, vb_tiles_below);
		
		layer_back = layer_create(0);
		layer_set_visible(layer_back, false);
		tiles_back = layer_tilemap_create(layer_back, x, y, tl_tiles, _lv_w, _lv_h);
		
		layer_back_glass = layer_create(110)
		layer_set_visible(layer_back_glass, false)
		tiles_back_glass = layer_tilemap_create(layer_back_glass, x, y, tl_tiles, _lv_w, _lv_h);
		
		level_unpack_bin_layer_free_map_filtered(
			_buffer, _info.content.layers[$ "Background"].pointer,
			tiles_back, tiles_back_glass
		);
		
		layer_tiles_above = layer_create(0);
		layer_set_visible(layer_tiles_above, false);
		tiles_tiles_above = layer_tilemap_create(layer_tiles_above, x, y, tl_tiles, _lv_w, _lv_h);
		level_unpack_bin_layer_free_map(_buffer, _info.content.layers[$ "TilesAbove"].pointer, tiles_tiles_above);
		
		layer_decor = layer_create(0);
		layer_set_visible(layer_decor, false);
		tiles_decor = layer_tilemap_create(layer_decor, x, y, tl_tiles, _lv_w, _lv_h);
		level_unpack_bin_layer_free_map(_buffer, _info.content.layers[$ "Decor"].pointer, tiles_decor);
		
		layer_decor_under = layer_create(0);
		layer_set_visible(layer_decor_under, false);
		tiles_decor_under = layer_tilemap_create(layer_decor_under, x, y, tl_tiles, _lv_w, _lv_h);
		level_unpack_bin_layer_free_map(_buffer, _info.content.layers[$ "DecorUnder"].pointer, tiles_decor_under);
		
		layer_spike = layer_create(0);
		layer_set_visible(layer_spike, false);
		tiles_spike = layer_tilemap_create(layer_spike, x, y, tl_debug_spikes, _lv_w, _lv_h);
		level_unpack_bin_layer_grid(_buffer, _info.content.layers[$ "Spikes"].pointer, tiles_spike);
		
		buffer_delete(_buffer);
		
		entities = [];
		
		var _layernames = struct_get_names(_info.content.layers);
		for (var i_layer = 0; i_layer < array_length(_layernames); i_layer++) {
			switch _layernames[i_layer] {
				case "Bubbles":
				case "Walls":
				case "Lights":
				case "Meta":
				case "Instances": {
					var _entities = _info.content.layers[$ _layernames[i_layer]].entities;
					for (var i_entity = 0; i_entity < array_length(_entities); i_entity++) {
						var _e = _entities[i_entity];
						
						if global.entities_toc[$ _e.id] != undefined {
							continue;
						}
						
						var _object_index = asset_get_index(_e.name);
						
						var _field = _e.fields; // this just seems like such a good idea!
						_field.uid = _e.id;
						
						// @todo: rewrite
						if array_contains(_e.tags, "SIZE_TILE") {
							_field.image_xscale = floor(_e.width / TILESIZE);
							_field.image_yscale = floor(_e.height / TILESIZE);
						}
						
						var _pos_x = _e.x,
							_pos_y = _e.y;
						
						if array_contains(_e.tags, "CENTERED") {
							_pos_x += 8;
							_pos_y += 8;
						}
						
						var _collect = {
							id: _e.id,
							x: _pos_x,
							y: _pos_y,
							layer: _layernames[i_layer],
							object: _object_index,
							field: _field,
						};
			
						global.entities[$ _e.id] = noone;
						
						array_push(entities, _collect);
					}
				}
			}
		}
		
		show_debug_message("level: parse: {0}", (get_timer() - _time) / 1000)
	}
	
	/// creates tile data from file
	static prepare = function() {
		
	}
	
	/// flags level as loaded, loads entities
	static load = function() {
		
		if loaded return;
		loaded = true;
		
		for (var i_entity = 0; i_entity < array_length(entities); i_entity++) {
			var _e = entities[i_entity]
			
			var _exists = false;

			with _e.object {
				if !variable_instance_exists(self, "uid") continue;
				if uid == _e.id {
					_exists = true;
					break;
				}
			}

			if _exists continue;

			var _inst = instance_create_layer(
				_e.x, _e.y, 
				_e.layer,
				_e.object,
				_e.field
			);
			
			global.entities[$ _e.id] = _inst;
			
		}
		
		if shadow_vb == -1 {
			game_level_setup_light(self);
		}
		
	}
	
	/// flags level as 'unloaded', probably destroying 
	/// it's associated entities in the process.
	static unload = function() {
		
		if !loaded return;
		loaded = false;
		
		//if shadow_vb != -1 {
		//	vertex_delete_buffer(shadow_vb);
		//	shadow_vb = -1;
		//}
	
	}
	
	/// destroys tile data.
	static destroy = function() {
		
	}
	
	
}

function game_level_setup_light(_level) {
	
	static _Quad = function(_vb, _x1, _y1, _x2, _y2) {
		vertex_position_3d(_vb, _x1, _y1, 0);
		vertex_position_3d(_vb, _x1, _y1, 1);
		vertex_position_3d(_vb, _x2, _y2, 0);
		
		vertex_position_3d(_vb, _x1, _y1, 1);
		vertex_position_3d(_vb, _x2, _y2, 0);
		vertex_position_3d(_vb, _x2, _y2, 1);
	};
	
	var _tiles = _level.tiles;
	var _x_off = _level.x;
	var _y_off = _level.y;
	
	var _vb = vertex_create_buffer();
	
	var _count = 0;
	
	vertex_begin(_vb, level_get_vf_shadows());
	
	for (var _x = 0; _x < tilemap_get_width(_tiles); _x++) {
		for (var _y = 0; _y < tilemap_get_height(_tiles); _y++) {
			
			if tilemap_get(_tiles, _x, _y) == 0 continue;
			
			var _cx = _x_off + _x * TILESIZE;
			var _cy = _y_off + _y * TILESIZE;
			var _h = TILESIZE;
			
			while _y < tilemap_get_height(_tiles) && tilemap_get(_tiles, _x, _y + 1) != 0 {
				_h += TILESIZE;
				_y++;
			}
			
			_Quad(
				_vb, 
				_cx, _cy, _cx + TILESIZE, _cy + _h
			);
			_Quad(
				_vb, 
				_cx + TILESIZE, _cy, _cx, _cy + _h
			);
			
			_count++;
				
		}
	}
	
	vertex_end(_vb);
	
	if _count > 0 vertex_freeze(_vb);
	
	show_debug_message($"{_count} shadow tiles")
	
	_level.shadow_vb = _vb;
	
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
function game_level_get_safe_rect(_x1, _y1, _x2, _y2) {
	for (var i = 0; i < array_length(level.loaded); i++) {
		var _lvl = level.loaded[i];
		if rectangle_in_rectangle(
				_x1, _y1, _x2, _y2,
				_lvl.x, _lvl.y,
				_lvl.x + _lvl.width,
				_lvl.y + _lvl.height) {
			return _lvl;
		}
	}
	return undefined;
}
function game_level_get_safe(_x, _y) {
	return game_level_get_safe_rect(_x, _y, _x + 1, _y + 1)
}

function game_level_onscreen() {
	var _cam = game_camera_get();
	
	static _pad = 16
	
	static __out = []
	static __cache_x = 0
	static __cache_y = 0
	
	if __cache_x != _cam.x || __cache_y != _cam.y {
		array_delete(__out, 0, array_length(__out)); // hopefully this is fine
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
				array_push(__out, _lvl)
			}
		}
	}
	
	return __out;
}

function game_level_get_data(_x, _y) {
	var _lvl = game_level_get(_x, _y);
	return game_level_grab_data(_lvl);
}

function game_level_grab_data(_lvl) {
	
	static __return = {
		area: undefined,
		biome: undefined,
		background: undefined,
		music: undefined,
		lut_grade: "base",
		lut_mix: 1,
		flags: [],
	};
	
	if !_lvl return __return;
	
	__return.biome = "none";
	__return.background = "none";
	__return.music = undefined;
	__return.lut_grade = "base";
	__return.lut_mix = 1;
	static __empty = [];
	array_delete(__empty, 0, array_length(__empty));
	__return.flags = __empty;
	
	// oh no
	switch _lvl.fields.preset {
		case "hub_0":
			__return.area = "hub";
			__return.background = "judge";
			__return.biome = "smoke";
			array_push(__return.flags, "hub");
			break;
		
		case "area0_1":
			__return.area = "area0";
			__return.background = "glow";
			__return.music = "stars";
			__return.biome = "dust";
			break;
		case "area0_2":
			__return.area = "area0";
			__return.background = "clouds";
			__return.music = "stars";
			__return.biome = "dust";
			break;
			
		case "area1_1":
			__return.area = "area1";
			__return.background = "city";
			__return.music = "story";
			__return.biome = "rain";
			__return.lut_grade = "vaporwave";
			__return.lut_mix = 0.25;
			break;
		case "area1_2":
			__return.area = "area1";
			__return.background = "boxes";
			__return.music = "story";
			__return.biome = "dust";
			__return.lut_grade = "vaporwave";
			__return.lut_mix = 0.1;
			break;
	}
	
	// this feels like a terrible idea
	__return.biome = _lvl.fields.biome ?? __return.biome;
	__return.background = _lvl.fields.background ?? __return.background;
	__return.music =
		(_lvl.fields.music != undefined && _lvl.fields.music != "null")
		? _lvl.fields.music : __return.music;
	__return.lut_grade = _lvl.fields.lut_grade ?? __return.lut_grade;
	__return.lut_mix = _lvl.fields.lut_mix ?? __return.lut_mix;
	for (var i = 0; i < array_length(_lvl.fields.flags); i++) {
		array_push(__return.flags, _lvl.fields.flags[i]);
	}
	
	return __return;
}

function game_level_get_biome(_x, _y) {
	return game_level_get_data(_x, _y).biome;
}
function game_level_get_background(_x, _y) {
	return game_level_get_data(_x, _y).background;
}
function game_level_get_music(_x, _y) {
	var _out = game_level_get_data(_x, _y);
	if !_out return undefined;
	return _out.music;
}
function game_level_get_lut(_x, _y) {
	static __return = {}
	var _data = game_level_get_data(_x, _y);
	__return.grade = _data.lut_grade;
	__return.mix = _data.lut_mix;
	return __return;
}
function game_level_get_flags(_x, _y) {
	return game_level_get_data(_x, _y).flags;
}
