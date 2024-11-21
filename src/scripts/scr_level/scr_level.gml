
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


/// @arg {id.Buffer} _buffer
function level_unpack_bin_field(_buffer) {
	
	var _name = buffer_read(_buffer, buffer_string);
	var _type = buffer_read(_buffer, buffer_u8);
	var _isnull = buffer_read(_buffer, buffer_bool);
	
	var _value;
	
	switch (_type) {
		case 255:
			var _array_type = buffer_read(_buffer, buffer_u8);
			var _array_length = buffer_read(_buffer, buffer_u8);
			_value = [];
			for (var i = 0; i < _array_length; i++) {
				buffer_read(_buffer, buffer_u8); // lol
				var _out = level_unpack_bin_field_inner(_buffer, _array_type);
				array_push(_value, _out);
			}
			break;
		default:
			_value = level_unpack_bin_field_inner(_buffer, _type);
			break;
	}
	
	if _isnull _value = undefined;
	
	return {
		name: _name,
		value: _value,
	};
	
}

/// @arg {id.Buffer} _buffer
/// @arg {real} _type
function level_unpack_bin_field_inner(_buffer, _type) {
	
	var _value;
	
	switch _type {
		case 0:
			_value = buffer_read(_buffer, buffer_u64);
			break;
		case 1:
			_value = buffer_read(_buffer, buffer_f64);
			break;
		case 2:
			_value = buffer_read(_buffer, buffer_bool);
			break;
		case 3:
			_value = buffer_read(_buffer, buffer_string);
			break;
		case 4:
			var _r = buffer_read(_buffer, buffer_u8);
			var _g = buffer_read(_buffer, buffer_u8);
			var _b = buffer_read(_buffer, buffer_u8);
			_value = make_color_rgb(_r, _g, _b);
			break;
		case 5:
			var _x = buffer_read(_buffer, buffer_u32);
			var _y = buffer_read(_buffer, buffer_u32);
			_value = {
				x: _x,
				y: _y,
			};
			break;
		case 6:
			_value = buffer_read(_buffer, buffer_string);
			break;
		default:
			show_debug_message($"impending doom... {_type}");
			break;
	}
		
	return _value;
	
}

function level_unpack_bin_main(_buffer) {
	
	var _rooms = [];
	
	var _room_count = buffer_read(_buffer, buffer_u32);
	for (var i_room = 0; i_room < _room_count; i_room++) {
		
		var _room_name = buffer_read(_buffer, buffer_string);
		var _room_id = buffer_read(_buffer, buffer_string);
		
		var _room_x = buffer_read(_buffer, buffer_u32);
		var _room_y = buffer_read(_buffer, buffer_u32);
		var _room_width = buffer_read(_buffer, buffer_u32);
		var _room_height = buffer_read(_buffer, buffer_u32);
		
		var _room_fields = {};
		
		var _fields_count = buffer_read(_buffer, buffer_u8);
		for (var i_field = 0; i_field < _fields_count; i_field++) {
			var _field = level_unpack_bin_field(_buffer);
			_room_fields[$ _field.name] = _field.value;
		}
		
		array_push(_rooms, {
			name: _room_name,
			id: _room_id,
			x: _room_x, y: _room_y,
			width: _room_width, height: _room_height,
			fields: _room_fields,
		});
	}
	
	var _toc = [];
	
	var _toc_count = buffer_read(_buffer, buffer_u32);
	for (var i_toc = 0; i_toc < _toc_count; i_toc++) {
		
		var _toc_type = buffer_read(_buffer, buffer_u8);
		var _toc_id = buffer_read(_buffer, buffer_string);
		
		var _toc_x = buffer_read(_buffer, buffer_u32);
		var _toc_y = buffer_read(_buffer, buffer_u32);
		var _toc_width = buffer_read(_buffer, buffer_u32);
		var _toc_height = buffer_read(_buffer, buffer_u32);
		
		var _toc_object = "";
		
		var _toc_fields = {};
		
		switch _toc_type {
			case 0:
				_toc_object = nameof(obj_player);
				break;
			case 1:
				_toc_object = nameof(obj_checkpoint);
				_toc_fields.index = buffer_read(_buffer, buffer_string);
				break;
			case 2:
				_toc_object = nameof(obj_timer_start);
				_toc_fields.name = buffer_read(_buffer, buffer_string);
				_toc_fields.time = buffer_read(_buffer, buffer_f32);
				_toc_fields.dir = buffer_read(_buffer, buffer_string);
				_toc_fields.ref = buffer_read(_buffer, buffer_string);
				break;
			case 3:
				_toc_object = nameof(obj_timer_end);
				break;
		}
		
		array_push(_toc, {
			object: _toc_object,
			id: _toc_id,
			x: _toc_x, y: _toc_y,
			width: _toc_width, height: _toc_height,
			fields: _toc_fields,
		});
	}
	
	return {
		rooms: _rooms,
		toc: _toc,
	};
}

function level_unpack_bin_room(_buffer) {
	
	var _name = buffer_read(_buffer, buffer_string);
	
	var _layers = {};
	
	var _layer_count = buffer_read(_buffer, buffer_u8);
	repeat _layer_count {
		var _layer_name = buffer_read(_buffer, buffer_string);
		var _layer_type = buffer_read(_buffer, buffer_u8);
		
		var _layer;
		
		switch _layer_type {
			case 0:
				var _tiles_width = buffer_read(_buffer, buffer_u32);
				var _tiles_count = buffer_read(_buffer, buffer_u32);
				var _tiles_height = _tiles_count / _tiles_width;
			
				var _layer_id = layer_create(0);
				layer_set_visible(_layer_id, false);
				var _layer_tiles = layer_tilemap_create(
						_layer_id, 0, 0, tl_tiles,
						_tiles_width, _tiles_height
					);
			
				for (var i_tile = 0; i_tile < _tiles_count; i_tile++) {
					var _tile = buffer_read(_buffer, buffer_u8);
					tilemap_set(_layer_tiles, _tile, i_tile mod _tiles_width, i_tile div _tiles_width);
				}
			
				_layer = {
					layer: _layer_id,
					tiles: _layer_tiles
				};
			break;
			case 1:
				var _entities = [];
				var _entities_count = buffer_read(_buffer, buffer_u32);
				repeat _entities_count {
					var _entity_name = buffer_read(_buffer, buffer_string);
					var _entity_id = buffer_read(_buffer, buffer_string);
					
					var _entity_tags = [];
					var _entity_tags_count = buffer_read(_buffer, buffer_u8);
					repeat _entity_tags_count {
						var _entity_tag = buffer_read(_buffer, buffer_string);
						array_push(_entity_tags, _entity_tag);
					}
					
					var _entity_x = buffer_read(_buffer, buffer_u32);
					var _entity_y = buffer_read(_buffer, buffer_u32);
					var _entity_width = buffer_read(_buffer, buffer_u32);
					var _entity_height = buffer_read(_buffer, buffer_u32);
					
					var _entity_fields = {};
					var _entity_fields_count = buffer_read(_buffer, buffer_u8);
					repeat _entity_fields_count {
						var _entity_field = level_unpack_bin_field(_buffer);
						_entity_fields[$ _entity_field.name] = _entity_field.value;
					}
					
					array_push(_entities, {
						object: _entity_name,
						id: _entity_id,
						tags: _entity_tags,
						x: _entity_x, y: _entity_y,
						width: _entity_width, height: _entity_height,
						fields: _entity_fields,
					});
				}
				_layer = {
					entities: _entities,
				};
			break;
			case 2:
			case 3:
				var _tiles_count = buffer_read(_buffer, buffer_u32);	
			
				var _tiles_buffer = vertex_create_buffer();
				vertex_begin(_tiles_buffer, level_get_vf());
			
				var _ts_info = tileset_get_info(tl_tiles);
				var _ts_width = _ts_info.tile_width + 2 * _ts_info.tile_horizontal_separator;
				var _ts_height = _ts_info.tile_height + 2 * _ts_info.tile_vertical_separator;
			
				var _tex_rx = texture_get_texel_width(_ts_info.texture);
				var _tex_ry = texture_get_texel_height(_ts_info.texture);
			
				var _uv_x = tileset_get_uvs(tl_tiles)[0];
				var _uv_y = tileset_get_uvs(tl_tiles)[1];
			
				repeat _tiles_count {
					var _t = buffer_read(_buffer, buffer_u32);
					var _t_x = buffer_read(_buffer, buffer_u32);
					var _t_y = buffer_read(_buffer, buffer_u32);
			
					var _ts_tile_x = (_t mod _ts_info.tile_columns) * _ts_width;
					var _ts_tile_y = (_t div _ts_info.tile_columns) * _ts_height;
			
					var _uv_t_x = _uv_x + _ts_tile_x * _tex_rx;
					var _uv_t_y = _uv_y + _ts_tile_y * _tex_ry;
			
					// tri 1
					vertex_position(_tiles_buffer, _t_x, _t_y);
					vertex_texcoord(_tiles_buffer, _uv_t_x, _uv_t_y);
			
					vertex_position(_tiles_buffer, _t_x + TILESIZE, _t_y);
					vertex_texcoord(_tiles_buffer, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y);
			
					vertex_position(_tiles_buffer, _t_x + TILESIZE, _t_y + TILESIZE);
					vertex_texcoord(_tiles_buffer, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry);
			
					// tri 2
					vertex_position(_tiles_buffer, _t_x, _t_y);
					vertex_texcoord(_tiles_buffer, _uv_t_x, _uv_t_y);
			
					vertex_position(_tiles_buffer, _t_x, _t_y + TILESIZE);
					vertex_texcoord(_tiles_buffer, _uv_t_x, _uv_t_y + TILESIZE * _tex_ry);
			
					vertex_position(_tiles_buffer, _t_x + TILESIZE, _t_y + TILESIZE);
					vertex_texcoord(_tiles_buffer, _uv_t_x + TILESIZE * _tex_rx, _uv_t_y + TILESIZE * _tex_ry);
				}
				
				vertex_end(_tiles_buffer);
				
				_layer = {
					buffer: _tiles_buffer
				};
			break;
			default:
				show_debug_message($"impending doom... {_layer_type}");
		}
		
		_layer.name = _layer_name;
		_layers[$ _layer_name] = _layer;
	}
	
	return {
		name: _name,
		layers: _layers,
	};
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
	
	// front tiles
	layer_front = -1;
	tiles_front = -1;
	
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
	static init = function(_level, _local) {
		
		var _lv_x = _level.x div TILESIZE,
			_lv_y = _level.y div TILESIZE,
			_lv_w = _level.height div TILESIZE,
			_lv_h = _level.width div TILESIZE;
	
		x = _lv_x * TILESIZE;
		y = _lv_y * TILESIZE;
		width = _lv_w * TILESIZE;
		height = _lv_h * TILESIZE;
		
		fields = _level.fields;
				
		layer = _local.layers[$ "Collisions"].layer;
		tiles = _local.layers[$ "Collisions"].tiles;
		
		layer_front = layer_create(0)
		layer_set_visible(layer_front, false)
		tiles_front = layer_tilemap_create(layer_front, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
				
		layer_back = layer_create(110)
		layer_set_visible(layer_back, false)
		tiles_back = layer_tilemap_create(layer_back, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
		
		layer_back_glass = layer_create(110)
		layer_set_visible(layer_back_glass, false)
		tiles_back_glass = layer_tilemap_create(layer_back_glass, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
		
		layer_tiles_above = layer_create(109)
		layer_set_visible(layer_tiles_above, false)
		tiles_tiles_above = layer_tilemap_create(layer_tiles_above, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
		
		layer_decor = layer_create(109)
		layer_set_visible(layer_decor, false)
		tiles_decor = layer_tilemap_create(layer_decor, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
		
		layer_decor_under = layer_create(-1)
		layer_set_visible(layer_decor_under, false)
		tiles_decor_under = layer_tilemap_create(layer_decor_under, x, y, tl_tiles, width / TILESIZE, height / TILESIZE);
		
		layer_spike = layer_create(-1)
		layer_set_visible(layer_spike, false)
		tiles_spike = layer_tilemap_create(layer_spike, x, y, tl_debug_spikes, width / TILESIZE, height / TILESIZE);
		
		
		var _time = get_timer();
		
		entities = []
		
		/*
		
		for (var i_layer = 0; i_layer < array_length(_level.layerInstances); i_layer++) {
			var _layer = _level.layerInstances[i_layer];

			switch _layer.__identifier {
				
				case "Tiles":
					// construct stupid vertex buffer stuff
					// the things i do for 2 pixels
					vb_front = vertex_create_buffer()
					level_ldtk_buffer(_layer.autoLayerTiles, vb_front)
				
					break;
				case "TilesBelow":
					vb_tiles_below = vertex_create_buffer()
					level_ldtk_buffer(_layer.autoLayerTiles, vb_tiles_below)
					
					break;
				case "TilesAbove":
					level_ldtk_tiles(_layer.autoLayerTiles, tiles_tiles_above);
					
					break;
				case "Decor":
					level_ldtk_tiles(_layer.gridTiles, tiles_decor);
					
					break;
				case "DecorUnder":
					level_ldtk_tiles(_layer.gridTiles, tiles_decor_under);
					
					break;
				case "Background": 
					level_ldtk_tiles_window(_layer.autoLayerTiles, tiles_back, tiles_back_glass);
					
					break;
				case "Collisions":
					level_ldtk_intgrid(_layer, tiles);
					
					break;
				case "Spikes":
					level_ldtk_intgrid(_layer, tiles_spike);
					
					break;
				
				case "Bubbles":
				case "Walls":
				case "Lights":
				case "Meta":
				case "Instances":
					
					for (var i_entity = 0; i_entity < array_length(_layer.entityInstances); i_entity++) {
						var _e = _layer.entityInstances[i_entity]
						
						if global.entities_toc[$ _e.iid] != undefined {
							continue;
						}
						
						var _object_index = asset_get_index(_e.__identifier);
						
						var _field = {};
						
						_field.uid = _e.iid;
						
						for (var i_field = 0; i_field < array_length(_e.fieldInstances); i_field++) {
							var _f = _e.fieldInstances[i_field];
							_field[$ _f.__identifier] = level_ldtk_field(_f, x, y);
						}
						
						// @todo: rewrite
						if array_contains(_e.__tags, "SIZE_TILE") {
							_field.image_xscale = floor(_e.width / TILESIZE);
							_field.image_yscale = floor(_e.height / TILESIZE);
						} else {
							// find the entity definition for some reason ???
							var _def = array_find_index(_defs.entities, method({_e}, function(_i){
								return _i.identifier == _e.__identifier;
							}))
							if _def != -1 {
								_def = _defs.entities[_def];
							} else {
								if _def {
									show_debug_message("what the fuck?");
									_field.image_xscale = floor(_e.width / _def.width);
									_field.image_yscale = floor(_e.height / _def.height);
								} else {
									_field.image_xscale = floor(_e.width / TILESIZE);
									_field.image_yscale = floor(_e.height / TILESIZE);
								}
							}
						}
						
						var _pos_x = _e.__worldX,
							_pos_y = _e.__worldY;
						
						if array_contains(_e.__tags, "CENTERED") {
							_pos_x += 8;
							_pos_y += 8;
						}
						
						var _collect = {
							id: _e.iid,
							x: _pos_x,
							y: _pos_y,
							layer: _layer.__identifier,
							object: _object_index,
							field: _field,
						};

						global.entities[$ _e.iid] = noone;
						
						array_push(entities, _collect);
						
					}
					
					break;
				
			}
		}
		*/
		
		show_debug_message("unpack: {0}", (get_timer() - _time) / 1000)
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
