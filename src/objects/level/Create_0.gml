
#macro TILESIZE 16

file = game_json_open("test.ldtk");

levels = [];

max_width = room_width;
max_height = room_height;

for (var i = 0; i < array_length(file.levels); i++) {
	
	var _level = file.levels[i];
	
	var _lv_x = floor(_level.worldX / TILESIZE),
		_lv_y = floor(_level.worldY / TILESIZE),
		_lv_w = floor(_level.pxWid / TILESIZE),
		_lv_h = floor(_level.pxHei / TILESIZE);
	
	max_width = max(max_width, (_lv_x + _lv_w) * TILESIZE);
	max_height = max(max_height, (_lv_y + _lv_h) * TILESIZE);
	
	var _lvl = {};
	_lvl.layer = layer_create(0);
	_lvl.tiles = layer_tilemap_create(
		_lvl.layer,
		_lv_x * TILESIZE, _lv_y * TILESIZE,
		tl_debug, 
		_lv_w, _lv_h
	);
	
	array_push(levels, _lvl);
	
	for (var j = 0; j < array_length(_level.layerInstances); j++) {
		
		var _layer = _level.layerInstances[j];
		
		switch _layer.__identifier {
			
			case "Tiles":
				
				for (var n = 0; n < array_length(_layer.intGridCsv); n++) {
					
					var _tx = n % _layer.__cWid;
					var _ty = floor(n / _layer.__cWid);
					var _t = _layer.intGridCsv[n];
					
					tilemap_set(_lvl.tiles, _t, _tx, _ty);
					
				}
				
				break;
			
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
							case "EntityRef":
								// todo
								
								break;
						}
						_field[$ _f.__identifier] = _val;
					}
					
					_field.image_xscale = floor(_e.width / TILESIZE);
					_field.image_yscale = floor(_e.height / TILESIZE);
					
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
