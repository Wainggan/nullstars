
function actor_move_x(_amount, _callback = undefined) {
	
	x_rem += _amount;
	
	var _move = round(x_rem);
	if _move != 0 {
		
		x_rem -= _move;
		var _sign = sign(_move);
		
		while _move != 0 {
			if !place_meeting(x + _sign, y, obj_wall) {
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
			if !place_meeting(x, y + _sign, obj_wall) {
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
		_x2 = tilemap_get_cell_x_at_pixel(_tm, bbox_right + (_x - x), y),
		_y2 = tilemap_get_cell_y_at_pixel(_tm, x, bbox_bottom + (_y - y));

	for (var _x = _x1; _x <= _x2; _x++) {
		for (var _y = _y1; _y <= _y2; _y++) {
			if(tile_get_index(tilemap_get(_tm, _x, _y))){
				return true;
			}
		}
	}

	return place_meeting(_x, _y, obj_wall);
}

