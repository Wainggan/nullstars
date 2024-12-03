
function actor_lift_get_x() {
	if lift_x == 0 && lift_y == 0 {
		return lift_last_x;
	}
	return lift_x;
}
function actor_lift_get_y() {
	if lift_x == 0 && lift_y == 0 {
		return lift_last_y;
	}
	return lift_y;
}

function actor_lift_set(_x, _y) {
	lift_x = _x;
	lift_y = _y;
	if _x != 0 && _y != 0 {
		lift_last_x = _x;
		lift_last_y = _y;
		lift_last_time = 10;
	}
}

/// should be called *after* the object has completed its main update
function actor_lift_update() {
	actor_lift_set(0, 0);
	lift_last_time -= 1;
	if lift_last_time <= 0 {
		lift_last_x = 0;
		lift_last_y = 0;
	}
}


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
	
	static __list = ds_list_create()
	
	for (var i = 0; i < array_length(level.loaded); i++) {
		if place_meeting(_x, _y, level.loaded[i].tiles) return true;
	}
	
	ds_list_clear(__list)
	instance_place_list(_x, _y, obj_Solid, __list, false);
	
	for (var i = 0; i < ds_list_size(__list); i++) {
		var _o = __list[| i];
		if _o.collidable {
			
			if object_get_parent(_o.object_index) == obj_ss {
				
				if _o.object_index == obj_ss_up && _o.bbox_top >= bbox_bottom {
					return true;
				}
				if _o.object_index == obj_ss_down && _o.bbox_bottom <= bbox_top {
					return true;
				}
				if _o.object_index == obj_ss_left && _o.bbox_left >= bbox_right {
					return true;
				}
				if _o.object_index == obj_ss_right && _o.bbox_right <= bbox_left {
					return true;
				}
				
			} else {
				return true;
			}
		}
	}
	
	return false;
}

