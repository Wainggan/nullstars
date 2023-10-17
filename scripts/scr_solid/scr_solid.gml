
function solid_move(_xv, _yv) {
	
	x_rem += _xv;
	y_rem += _yv;   
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
					} else if array_get_index(_riding, self) != -1 {
						actor_move_x(_moveX);
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

		collidable = true;
	}
	
}
