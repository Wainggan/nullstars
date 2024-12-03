
function solid_move(_xv, _yv) {
	
	static __riding = [];
	array_delete(__riding, 0, array_length(__riding));
	with obj_Actor {
		if riding(other) array_push(__riding, self);
	}
	
	x_rem += _xv;
	y_rem += _yv;
	
	lift_x = _xv;
	lift_y = _yv;
	
	var _moveX = round(x_rem);
	var _moveY = round(y_rem);
	
	if _moveX != 0 || _moveY != 0 {
		
		var _last_collide = collidable;
		collidable = false;

		if _moveX != 0 {
			x_rem -= _moveX;
			x += _moveX;
			if _moveX > 0 {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_x(other.bbox_right - bbox_left, squish);
						actor_lift_set(other.lift_x, other.lift_y);
					} else if array_get_index(__riding, self) != -1 {
						actor_move_x(_moveX);
						actor_lift_set(other.lift_x, other.lift_y);
					}
				}
			} else {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_x(other.bbox_left - bbox_right, squish);
						actor_lift_set(other.lift_x, other.lift_y);
					} else if array_get_index(__riding, self) != -1 {
						actor_move_x(_moveX);
						actor_lift_set(other.lift_x, other.lift_y);
					}
				}
			}
		}
		
		if _moveY != 0 {
			y_rem -= _moveY;
			y += _moveY;
			if _moveY > 0 {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_y(other.bbox_bottom - bbox_top, squish);
						actor_lift_set(other.lift_x, other.lift_y);
					} else if array_get_index(__riding, self) != -1 {
						actor_move_y(_moveY);
						actor_lift_set(other.lift_x, other.lift_y);
					}
				}
			} else {
				with obj_Actor {
					if place_meeting(x, y, other) {
						actor_move_y(other.bbox_top - bbox_bottom, squish);
						actor_lift_set(other.lift_x, other.lift_y);
					} else if array_get_index(__riding, self) != -1 {
						actor_move_y(_moveY);
						actor_lift_set(other.lift_x, other.lift_y);
					}
				}
			}
		}

		collidable = _last_collide;
	}
	
}


