
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
	
	for (var i = 0; i < array_length(level.levels); i++) {
		if place_meeting(_x, _y, level.levels[i].tiles) return true;
	}
	
	var _list = ds_list_create();
	
	instance_place_list(_x, _y, obj_Solid, _list, false);
	
	for (var i = 0; i < ds_list_size(_list); i++) {
		var _o = _list[| i];
		if _o.collidable {
			
			if object_get_parent(_o.object_index) == obj_ss {
				
				if _o.object_index == obj_ss_up && _o.bbox_top >= bbox_bottom {
					ds_list_destroy(_list)
					return true;
				}
				if _o.object_index == obj_ss_down && _o.bbox_bottom <= bbox_top {
					ds_list_destroy(_list)
					return true;
				}
				if _o.object_index == obj_ss_left && _o.bbox_left >= bbox_right {
					ds_list_destroy(_list)
					return true;
				}
				if _o.object_index == obj_ss_right && _o.bbox_right <= bbox_left {
					ds_list_destroy(_list)
					return true;
				}
				
			} else {
				ds_list_destroy(_list)
				return true;
			}
		}
	}
	
	ds_list_destroy(_list)

	return false;
}

