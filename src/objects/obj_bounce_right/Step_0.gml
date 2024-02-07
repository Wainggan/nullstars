
if place_meeting(x, y, obj_player) {
	with obj_player {
		actor_move_x(other.bbox_right - bbox_left)
		bounce(1)
	}
}


var _inst = instance_place(x, y, boxable)
if _inst {
	with _inst {
		actor_move_y(abs(other.bbox_right - bbox_left));
		x_vel = 5
		y_vel = -2.5;
	}
}