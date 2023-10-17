
function actor_move_x(_amount, _callback = undefined) {
	
	x_rem += _amount;
	
	var _move = round(x_rem);
	if _move != 0 {
		
		x_rem -= _move;
		var _sign = sign(_move);
		
		while _move != 0 {
			if !actor_collision(x + _sign, y) {
				x += _sign;
				_move -= _sign;
			} else {
				if _callback != undefined
					_callback();
				break;
			}
		}
		
	}
	
}


function actor_move_y(_amount, _callback = undefined) {
	
	y_rem += _amount;
	
	var _move = round(y_rem);
	if _move != 0 {
		
		y_rem -= _move;
		var _sign = sign(_move);
		
		while _move != 0 {
			if !actor_collision(x, y + _sign) {
				y += _sign;
				_move -= _sign;
			} else {
				if _callback != undefined
					_callback();
				break;
			}
		}
		
	}
	
}

function actor_collision(_x, _y) {
	var _layer = "Collision", _tm = layer_tilemap_get_id(_layer);

	var _x1 = tilemap_get_cell_x_at_pixel(_tm, bbox_left + (_x - x), y),
		_y1 = tilemap_get_cell_y_at_pixel(_tm, x, bbox_top + (_y - y)),
		_x2 = tilemap_get_cell_x_at_pixel(_tm, bbox_right + (_x - x) - 1, y),
		_y2 = tilemap_get_cell_y_at_pixel(_tm, x, bbox_bottom + (_y - y) - 1);

	for (var _xx = _x1; _xx <= _x2; _xx++) {
		for (var _yy = _y1; _yy <= _y2; _yy++) {
			if tile_get_index(tilemap_get(_tm, _xx, _yy)) {
				return true;
			}
		}
	}
	
	var _list = ds_list_create();
	
	instance_place_list(_x, _y, obj_solid, _list, false);
	
	for (var i = 0; i < ds_list_size(_list); i++) {
		if _list[| i].collidable {
			ds_list_destroy(_list)
			return true;
		}
	}
	
	ds_list_destroy(_list)

	return false;
}

