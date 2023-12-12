
if place_meeting(x, y, obj_player) {
	with obj_player {
		actor_move_x(other.bbox_right - bbox_left)
		bounce(1)
	}
}
