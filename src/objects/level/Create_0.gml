
var _time = get_timer();

var _buffer = buffer_load("world.bin");
var _file = level_unpack_bin_main(_buffer);
buffer_delete(_buffer);

show_debug_message("main file: {0}", (get_timer() - _time) / 1000);

levels = [];

loaded = [];

x_min = 0;
y_min = 0;

x_max = room_width;
y_max = room_height;

// partition
for (var i = 0; i < 44/*array_length(_file.rooms)*/; i++) {
	var _level = new Level();
	
	var _time = get_timer();
	
	show_debug_message("level file: {0}", (get_timer() - _time) / 1000)
	
	_level.init(_file.rooms[i], $"room/{_file.rooms[i].name}.bin");
	
	array_push(levels, _level);
	
	delete _file_level;
}

for (var i_table = 0; i_table < array_length(_file.toc); i_table++) {
	
	var _item = _file.toc[i_table]

	var _field = {}
	
	var _val = _item.fields;
	
	switch _item.object {
		case nameof(obj_checkpoint):
			_field.index = _val.index;
			break;
		case nameof(obj_timer_start):
			_field.name = _val.name;
			_field.time = _val.time;
			_field.dir = _val.dir;
			_field.ref = _val.ref;
			
			_field.image_xscale = floor(_item.width / TILESIZE);
			_field.image_yscale = floor(_item.height / TILESIZE);
			break;
		case nameof(obj_timer_end):
			_field.image_xscale = floor(_item.width / TILESIZE);
			_field.image_yscale = floor(_item.height / TILESIZE);
			break;
	}
	
	_field.uid = _item.id;
	
	var _inst = instance_create_layer(
		_item.x, _item.y,
		"Instances",
		asset_get_index(_item.object),
		_field
	);
	
	global.entities[$ _item.id] = _inst
	global.entities_toc[$ _item.id] = _inst
		
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
