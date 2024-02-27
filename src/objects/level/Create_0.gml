
#macro TILESIZE 16

file = game_json_open("level.ldtk");

levels = [];

loaded = [];

x_min = 0;
y_min = 0;

x_max = room_width;
y_max = room_height;

// partition
for (var i = 0; i < array_length(file.levels); i++) {
	var _level = file.levels[i];
	
	var _lv_x = floor(_level.worldX / TILESIZE),
		_lv_y = floor(_level.worldY / TILESIZE),
		_lv_w = floor(_level.pxWid / TILESIZE),
		_lv_h = floor(_level.pxHei / TILESIZE);
	
	var _lvl = {};
	_lvl.x = _lv_x * TILESIZE;
	_lvl.y = _lv_y * TILESIZE;
	_lvl.width = _lv_w * TILESIZE;
	_lvl.height = _lv_h * TILESIZE;
	
	_lvl.base = _level;
	_lvl.loaded = false;
	_lvl.part = -1;
	
	array_push(levels, _lvl)
}

load = function (_base) {
	
	if _base.loaded {
		return;
	}
	_base.loaded = true;
	array_push(loaded, _base)
	
	var _level = _base.base;
	
	var _lv_x = floor(_level.worldX / TILESIZE),
		_lv_y = floor(_level.worldY / TILESIZE),
		_lv_w = floor(_level.pxWid / TILESIZE),
		_lv_h = floor(_level.pxHei / TILESIZE);
	
	x_min = max(x_min, _lv_x);
	y_min = max(y_min, _lv_y);
	
	x_max = max(x_max, (_lv_x + _lv_w) * TILESIZE);
	y_max = max(y_max, (_lv_y + _lv_h) * TILESIZE);
	
	var _lvl = {};
	_lvl.x = _lv_x * TILESIZE;
	_lvl.y = _lv_y * TILESIZE;
	_lvl.width = _lv_w * TILESIZE;
	_lvl.height = _lv_h * TILESIZE;
	
	_lvl.layer = layer_create(0);
	_lvl.tiles = layer_tilemap_create(
		_lvl.layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_debug, 
		_lv_w, _lv_h
	);
	layer_set_visible(_lvl.layer, false);
	_lvl.decor_layer = layer_create(-1);
	_lvl.decor_tiles = layer_tilemap_create(
		_lvl.decor_layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_tiles, 
		_lv_w, _lv_h
	);
	_lvl.spikes_layer = layer_create(0);
	_lvl.spikes_tiles = layer_tilemap_create(
		_lvl.spikes_layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_debug_spikes, 
		_lv_w, _lv_h
	);
	_lvl.tilemap_layer = layer_create(0);
	_lvl.tilemap_tiles = layer_tilemap_create(
		_lvl.tilemap_layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_tiles, 
		_lv_w, _lv_h
	);
	_lvl.decor_back_layer = layer_create(109);
	_lvl.decor_back_tiles = layer_tilemap_create(
		_lvl.decor_back_layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_tiles, 
		_lv_w, _lv_h
	);
	_lvl.background_layer = layer_create(110);
	_lvl.background_tiles = layer_tilemap_create(
		_lvl.background_layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_tiles, 
		_lv_w, _lv_h
	);
	
	_lvl.vb = -1;
	
	_lvl.fields = {};
	for (var j = 0; j < array_length(_level.fieldInstances); j++) {
		var _f = _level.fieldInstances[j]
		var _val = _f.__value;
		switch _f.__type {
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
		}
		_lvl.fields[$ _f.__identifier] = _val;
	}
	
	_lvl.loaded = true;
	_base.part = _lvl
	
	var _entity_refs = {};
	var _entity_ref_defer = [];
	
	for (var j = 0; j < array_length(_level.layerInstances); j++) {
		
		var _layer = _level.layerInstances[j];
		
		var _targetLayer = undefined;
		var _targetTiles = undefined
		
		switch _layer.__identifier {
			
			case "Decor":
				_targetTiles ??= _layer.gridTiles;
			case "DecorUnder":
				_targetTiles ??= _layer.gridTiles;
				_targetLayer ??= _lvl.decor_back_tiles
			case "_Decor":
				_targetLayer ??= _lvl.decor_tiles
			case "Tiles":
				_targetLayer ??= _lvl.tilemap_tiles;
			case "Background":
				_targetLayer ??= _lvl.background_tiles;
				_targetTiles ??= _layer.autoLayerTiles;

				for (var n = 0; n < array_length(_targetTiles); n++) {
					
					var _td = _targetTiles[n];
					
					var _t_x = round(_td.px[0] / TILESIZE);
					var _t_y = round(_td.px[1] / TILESIZE);
					var _t = _td.t;
					
					tilemap_set(_targetLayer, _t, _t_x, _t_y);
					
				}
				
				break;
			
			case "Spikes":
				_targetLayer = _lvl.spikes_tiles;
			case "Collisions":
				_targetLayer ??= _lvl.tiles
				
				for (var n = 0; n < array_length(_layer.intGridCsv); n++) {
					
					var _tx = n % _layer.__cWid;
					var _ty = floor(n / _layer.__cWid);
					var _t = _layer.intGridCsv[n];
					
					tilemap_set(_targetLayer, _t, _tx, _ty);
					
				}
				
				break;
			
			case "Bubbles":
			case "Walls":
			case "Lights":
			case "Meta":
			case "Instances":
			
				break;
			
				var _entities = _layer.entityInstances;
				
				for (var n = 0; n < array_length(_entities); n++) {
					
					var _e  = _entities[n];
					
					var _field = {};
					
					var _ref_fields = [];
					
					for (var k = 0; k < array_length(_e.fieldInstances); k++) {
						var _f = _e.fieldInstances[k];
						var _josh = _f.__identifier;
						var _val = _f.__value;
						switch _f.__type {
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
								array_push(_ref_fields, [_josh, _val.entityIid]);
								_val = -1;
								
								break;
						}
						_field[$ _f.__identifier] = _val;
					}
					
					if array_contains(_e.__tags, "SIZE_TILE") {
						_field.image_xscale = floor(_e.width / TILESIZE);
						_field.image_yscale = floor(_e.height / TILESIZE);
					} else {
						// find the entity definition for some reason ???
						var _def = array_find_index(file.defs.entities, method({_e}, function(_i){
							return _i.identifier == _e.__identifier;
						}))
						if _def != -1 {
							_def = file.defs.entities[_def];
						} else {
							if _def {
								_field.image_xscale = floor(_e.width / _def.width);
								_field.image_yscale = floor(_e.height / _def.height);
							} else {
								_field.image_xscale = floor(_e.width / TILESIZE);
								_field.image_yscale = floor(_e.height / TILESIZE);
							}
						}
					}
					
					_field.uid = _e.iid;
					
					var _pos_x = _e.__worldX,
						_pos_y = _e.__worldY;
					
					if array_contains(_e.__tags, "CENTERED") {
						_pos_x += 8;
						_pos_y += 8;
					}
					
					var _object_index = asset_get_index(_e.__identifier);
					
					var _inst = instance_create_layer(
						_pos_x, _pos_y, 
						_layer.__identifier,
						_object_index,
						_field
					);
					
					if _object_index == obj_checkpoint {
						game_checkpoint_add(_inst)
					}
					
					_entity_refs[$ _e.iid] = _inst;
					
					for (var k = 0; k < array_length(_ref_fields); k++) {
						array_push(_entity_ref_defer, {
							inst: _inst,
							name: _ref_fields[k][0],
							id: _ref_fields[k][1]
						});
					}
					
				}
				
				for (var n = 0; n < array_length(_entity_ref_defer); n++) {
					variable_instance_set(
						_entity_ref_defer[n].inst,
						_entity_ref_defer[n].name,
						_entity_refs[$ _entity_ref_defer[n].id]
					);
				}
			
				break;
			
		}
		
	}
	
	render.setup_light(_lvl)
	
}

unload = function (_base) {
	if !_base.loaded {
		return;
	}
	_base.loaded = false;
	_base.part.loaded = false;
	
	array_delete(loaded, array_get_index(loaded, _base), 1);
	
	if _base.part.vb vertex_delete_buffer(_base.part.vb)
	
	layer_destroy(_base.part.layer)
	layer_tilemap_destroy(_base.part.tiles)
	
	layer_destroy(_base.part.decor_layer)
	layer_tilemap_destroy(_base.part.decor_tiles)
	
	layer_destroy(_base.part.spikes_layer)
	layer_tilemap_destroy(_base.part.spikes_tiles)
	
	layer_destroy(_base.part.tilemap_layer)
	layer_tilemap_destroy(_base.part.tilemap_tiles)
	
	layer_destroy(_base.part.decor_back_layer)
	layer_tilemap_destroy(_base.part.decor_back_tiles)
	
	layer_destroy(_base.part.background_layer)
	layer_tilemap_destroy(_base.part.background_tiles)
	
	// instances get destroyed by cultural osmosis later
	// (allows things like boxes to be moved outside an unloaded level without getting destroyed)
	
}

check = function () {
	
	var _cam = game_camera_get()
	
	for (var i = 0; i < array_length(levels); i++) {
		var _lvl = levels[i]
		
		if (_lvl.x <= _cam.x + _cam.w && _cam.x <= _lvl.x + _lvl.width)
		&& (_lvl.y <= _cam.y + _cam.h && _cam.y <= _lvl.y + _lvl.height) {
			load(_lvl)
		}
	}
	
}

// jesus christ
update = function () {
	
	var _cam = game_camera_get()
	
	for (var i = 0; i < array_length(loaded); i++) {
		var _lvl = loaded[i]
		if (_lvl.x <= _cam.x + _cam.w && _cam.x <= _lvl.x + _lvl.width)
		&& (_lvl.y <= _cam.y + _cam.h && _cam.y <= _lvl.y + _lvl.height) {
			continue; // yeag
		} else {
			unload(_lvl)
		}
	}
	
}



