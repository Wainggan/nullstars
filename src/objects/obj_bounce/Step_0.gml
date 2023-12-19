
if place_meeting(x, y, obj_player) {
	with obj_player {
		actor_move_y(other.bbox_top - y)
		bounce()
	}
}

var _inst = instance_place(x, y, [obj_ball, obj_box])
if _inst {
	with _inst {
		actor_move_y(-abs(other.bbox_top - bbox_bottom));
		y_vel = -7;
	}
}
