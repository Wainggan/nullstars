
#macro TILESIZE 16

file = game_json_open("level.ldtk");

levels = [];

max_width = room_width;
max_height = room_height;

// for the one time i need this
function hex_to_dec(_hex) {
    var _dec = 0;
 
    static _dig = "0123456789ABCDEF";
    var _len = string_length(_hex);
    for (var i = 1; i <= _len; i += 1) {
        _dec = _dec << 4 | (string_pos(string_char_at(_hex, i), _dig) - 1);
    }
 
    return _dec;
}

for (var i = 0; i < array_length(file.levels); i++) {
	
	var _level = file.levels[i];
	
	var _lv_x = floor(_level.worldX / TILESIZE),
		_lv_y = floor(_level.worldY / TILESIZE),
		_lv_w = floor(_level.pxWid / TILESIZE),
		_lv_h = floor(_level.pxHei / TILESIZE);
	
	max_width = max(max_width, (_lv_x + _lv_w) * TILESIZE);
	max_height = max(max_height, (_lv_y + _lv_h) * TILESIZE);
	
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
	_lvl.background_layer = layer_create(110);
	_lvl.background_tiles = layer_tilemap_create(
		_lvl.background_layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_tiles, 
		_lv_w, _lv_h
	);
	
	array_push(levels, _lvl);
	
	for (var j = 0; j < array_length(_level.layerInstances); j++) {
		
		var _layer = _level.layerInstances[j];
		
		var _targetLayer = _lvl.tiles;
		
		switch _layer.__identifier {
			
			case "Tiles":
				_targetLayer = _lvl.tilemap_tiles;

				for (var n = 0; n < array_length(_layer.autoLayerTiles); n++) {
					
					var _td = _layer.autoLayerTiles[n];
					
					var _tx = round(_td.px[0] / TILESIZE);
					var _ty = round(_td.px[1] / TILESIZE);
					var _t = _td.t;
					
					tilemap_set(_targetLayer, _t, _tx, _ty);
					
				}
				
				break;
			case "Background":
				_targetLayer = _lvl.background_tiles;

				for (var n = 0; n < array_length(_layer.autoLayerTiles); n++) {
					
					var _td = _layer.autoLayerTiles[n];
					
					var _tx = round(_td.px[0] / TILESIZE);
					var _ty = round(_td.px[1] / TILESIZE);
					var _t = _td.t;
					
					tilemap_set(_targetLayer, _t, _tx, _ty);
					
				}
				
				break;
				
			case "Spikes":
				_targetLayer = _lvl.spikes_tiles;
			case "Collisions":
				
				for (var n = 0; n < array_length(_layer.intGridCsv); n++) {
					
					var _tx = n % _layer.__cWid;
					var _ty = floor(n / _layer.__cWid);
					var _t = _layer.intGridCsv[n];
					
					tilemap_set(_targetLayer, _t, _tx, _ty);
					
				}
				
				break;
			
			case "Lights":
			case "Meta":
			case "Instances":
			
				var _entities = _layer.entityInstances;
				
				for (var n = 0; n < array_length(_entities); n++) {
					
					var _e  = _entities[n];
					
					var _field = {};
					
					for (var k = 0; k < array_length(_e.fieldInstances); k++) {
						var _f = _e.fieldInstances[k];
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
								// todo
								
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
					
					var _inst = instance_create_layer(
						_e.__worldX, _e.__worldY, 
						_layer.__identifier,
						asset_get_index(_e.__identifier),
						_field
					);
					
				}
			
				break;
			
		}
		
	}
	
}


render.setup_lights()
