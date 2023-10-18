
function solid_move(_xv, _yv) {
	
	x_rem += _xv;
	y_rem += _yv;
	x_lift = _xv;
	y_lift = _yv;
	var _moveX = round(x_rem);
	var _moveY = round(y_rem);
	
	if _moveX != 0 || _moveY != 0 {
		// todo: optimize
		var _riding = [];
		with obj_Actor {
			if riding(other) array_push(_riding, self);
		}

		collidable = false;

		if _moveX != 0 {
			x_rem -= _moveX;
			x += _moveX;
			if _moveX > 0 {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_x(other.bbox_right - bbox_left, squish);
						x_lift = _moveX;
					} else if array_get_index(_riding, self) != -1 {
						actor_move_x(_moveX);
						x_lift = _moveX;
					}
				}
			} else {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_x(other.bbox_left - bbox_right, squish);
					} else if array_get_index(_riding, self) != -1 {
						actor_move_x(_moveX);
					}
				}
			}
		}
		
		if _moveY!= 0 {
			y_rem -= _moveY;
			y += _moveY;
			if _moveY > 0 {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_y(other.bbox_bottom - bbox_top, squish);
						y_lift = _moveY;
					} else if array_get_index(_riding, self) != -1 {
						actor_move_y(_moveY);
						y_lift = _moveY;
					}
				}
			} else {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_y(other.bbox_top - bbox_bottom, squish);
						y_lift = _moveY;
					} else if array_get_index(_riding, self) != -1 {
						actor_move_y(_moveY);
						y_lift = _moveY;
					}
				}
			}
		}

		collidable = true;
	}
	
}

function solid_sim(_xv, _yv) {

	var _riding = [];
	with obj_Actor {
		if riding(other) array_push(_riding, self);
	}
	
	with obj_Actor {
		if array_get_index(_riding, self) != -1 {
			actor_move_x(_xv);
			actor_move_y(_yv);
			x_lift = _xv;
			y_lift = _yv;
		}
	}
	
	x_lift = _xv;
	y_lift = _yv;

}
