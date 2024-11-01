
var _file = game_json_open("level.ldtk");

levels = [];

loaded = [];

x_min = 0;
y_min = 0;

x_max = room_width;
y_max = room_height;

// partition
for (var i = 0; i < array_length(_file.levels); i++) {
	var _level = new Level()
	
	var _file_level = game_json_open(_file.levels[i].externalRelPath);
	
	_level.init(_file_level, _file.defs);
	
	array_push(levels, _level);
	
	delete _file_level;
}

for (var i_table = 0; i_table < array_length(_file.toc); i_table++) {
	
	var _item = _file.toc[i_table]
	
	for (var i_inst = 0; i_inst < array_length(_item.instancesData); i_inst++) {
		
		var _ent = _item.instancesData[i_inst]
		var _field = {}
		
		var _val = _ent.fields;
		
		switch _item.identifier {
			case nameof(obj_checkpoint):
				_field.index = level_ldtk_field_item(_val.index, "String");
				break;
			case nameof(obj_timer_start):
				_field.time = level_ldtk_field_item(_val.time, "Float")
				_field.dir = level_ldtk_field_item(_val.dir, "Enum")
				_field.ref = level_ldtk_field_item(_val.ref, "EntityRef")
				
				_field.image_xscale = floor(_ent.widPx / TILESIZE);
				_field.image_yscale = floor(_ent.heiPx / TILESIZE);
				break;
			case nameof(obj_timer_end):
				_field.image_xscale = floor(_ent.widPx / TILESIZE);
				_field.image_yscale = floor(_ent.heiPx / TILESIZE);
				break;
		}
		
		_field.uid = _ent.iids.entityIid;
		
		var _inst = instance_create_layer(
			_ent.worldX, _ent.worldY,
			"Instances",
			asset_get_index(_item.identifier),
			_field
		);
		
		global.entities[$ _ent.iids.entityIid] = _inst
		global.entities_toc[$ _ent.iids.entityIid] = _inst
		
	}
}


load = function (_base) {
	
	if _base.loaded {
		return;
	}
	
	_base.load()
	
	array_push(loaded, _base)
	
}

unload = function (_base) {
	
	if !_base.loaded {
		return;
	}
	
	_base.unload()
	
	array_delete(loaded, array_get_index(loaded, _base), 1);
	
	return;
	
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
	
	static __pad = 64;
	
	var _cam = game_camera_get()
	
	for (var i = 0; i < array_length(levels); i++) {
		var _lvl = levels[i]
		
		var _condition = false;
		_condition = _condition ||
			rectangle_in_rectangle(
				_lvl.x, _lvl.y, _lvl.x + _lvl.width, _lvl.y + _lvl.height,
				_cam.x - __pad, _cam.y - __pad,
				_cam.x + _cam.w + __pad, _cam.y + _cam.h + __pad
			);
		if instance_exists(obj_player) _condition = _condition ||
			point_in_rectangle(
				obj_player.x, obj_player.y, 
				_lvl.x, _lvl.y, _lvl.x + _lvl.width, _lvl.y + _lvl.height
			);
		
		if _condition {
			load(_lvl)
		} else {
			unload(_lvl)
		}
		
	}
	
}


// superstition
delete _file;
