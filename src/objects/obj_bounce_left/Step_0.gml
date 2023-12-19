
if place_meeting(x, y, obj_player) {
	with obj_player {
		actor_move_x(other.bbox_left - bbox_right)
		bounce(-1)
	}
}

var _inst = instance_place(x, y, [obj_ball, obj_box])
if _inst {
	with _inst {
		actor_move_y(-abs(other.bbox_left - bbox_right));
		x_vel = -5
		y_vel = -2.5;
	}
}
